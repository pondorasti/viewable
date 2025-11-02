const { chromium } = require("playwright")
const fs = require("fs")
const path = require("path")

async function scrapeSwiftUIDocs() {
  console.log("🚀 Starting SwiftUI documentation sidebar scraper...\n")

  const browser = await chromium.launch({
    headless: false, // Running in visible mode to see what's happening
    slowMo: 50, // Add small delay to see actions
  })

  try {
    const page = await browser.newPage()

    // Navigate to SwiftUI documentation
    console.log("📄 Navigating to SwiftUI documentation...")
    await page.goto("https://developer.apple.com/documentation/swiftui", {
      waitUntil: "networkidle",
      timeout: 60000,
    })

    // Wait for the sidebar to load - specifically the navigator
    console.log("⏳ Waiting for sidebar to load...")
    await page.waitForSelector("nav.navigator", { timeout: 30000 })

    // Wait a bit more to ensure all JavaScript has executed
    await page.waitForTimeout(2000)

    // Extract navigation incrementally as we scroll
    console.log("📜 Extracting navigation with incremental scrolling...")
    const navigationData = await extractNavigationIncrementally(page)

    // Save to JSON file
    const outputPath = path.join(__dirname, "output", "swiftui-sidebar.json")
    fs.writeFileSync(outputPath, JSON.stringify(navigationData, null, 2))

    console.log(`\n✅ Successfully saved navigation data to: ${outputPath}`)
    console.log(`📊 Total items extracted: ${countItems(navigationData)}`)

    console.log("\n⏸️  Browser will stay open for 20 seconds for inspection...")
    await page.waitForTimeout(20000)
  } catch (error) {
    console.error("❌ Error during scraping:", error)
    throw error
  } finally {
    await browser.close()
  }
}

async function extractNavigationIncrementally(page) {
  const allItems = new Map() // Store unique items by URL
  let totalScrolls = 0
  let noNewItemsCount = 0
  const maxNoNewItems = 3 // Stop after 3 scrolls with no new items

  // First, ensure we're in the SwiftUI context
  const currentContext = await page.evaluate(() => {
    const techTitle = document.querySelector(".technology-title")
    return techTitle ? techTitle.textContent.trim() : ""
  })

  console.log(`   ↳ Current context: ${currentContext}`)

  if (currentContext !== "SwiftUI") {
    // Try to click on SwiftUI if we're in All Technologies view
    const clickedSwiftUI = await page.evaluate(() => {
      const swiftUILink = Array.from(document.querySelectorAll("a")).find(
        (a) => a.textContent.trim() === "SwiftUI" && a.href.includes("/documentation/swiftui")
      )
      if (swiftUILink) {
        swiftUILink.click()
        return true
      }
      return false
    })

    if (clickedSwiftUI) {
      console.log("   ↳ Navigated back to SwiftUI")
      await page.waitForTimeout(2000)
    }
  }

  // Get scroll container info
  const scrollerInfo = await page.evaluate(() => {
    const scroller =
      document.querySelector(".vue-recycle-scroller") || document.querySelector("nav.navigator .card-body")
    if (scroller) {
      return {
        selector: scroller.className,
        scrollHeight: scroller.scrollHeight,
        clientHeight: scroller.clientHeight,
      }
    }
    return null
  })

  if (!scrollerInfo) {
    console.log("   ⚠️  Could not find scrollable container")
    return null
  }

  console.log(`   ↳ Found scrollable container: .${scrollerInfo.selector}`)
  console.log(
    `   ↳ Container height: ${scrollerInfo.clientHeight}px, Total scroll height: ${scrollerInfo.scrollHeight}px`
  )

  // Scroll to top first
  await page.evaluate(() => {
    const scroller =
      document.querySelector(".vue-recycle-scroller") || document.querySelector("nav.navigator .card-body")
    if (scroller) scroller.scrollTop = 0
  })

  // Incremental scrolling and extraction
  while (noNewItemsCount < maxNoNewItems) {
    const previousItemCount = allItems.size

    // Expand visible sections before extracting
    await expandVisibleSections(page)

    // Extract currently visible items
    const visibleItems = await extractVisibleItems(page)

    // Add new items to our collection
    visibleItems.forEach((item) => {
      if (!allItems.has(item.url)) {
        allItems.set(item.url, item)
      }
    })

    const newItemsFound = allItems.size - previousItemCount
    console.log(`   ↳ Scroll ${totalScrolls + 1}: Found ${newItemsFound} new items (total: ${allItems.size})`)

    if (newItemsFound === 0) {
      noNewItemsCount++
    } else {
      noNewItemsCount = 0
    }

    // Scroll down by approximately one viewport height
    const scrollComplete = await page.evaluate(() => {
      const scroller =
        document.querySelector(".vue-recycle-scroller") || document.querySelector("nav.navigator .card-body")
      if (scroller) {
        const previousTop = scroller.scrollTop
        const scrollAmount = scroller.clientHeight * 0.8 // Scroll 80% of viewport
        scroller.scrollTop += scrollAmount

        // Check if we've reached the bottom
        const atBottom = scroller.scrollTop + scroller.clientHeight >= scroller.scrollHeight - 10
        return {
          scrolled: scroller.scrollTop > previousTop,
          atBottom: atBottom,
        }
      }
      return { scrolled: false, atBottom: true }
    })

    if (scrollComplete.atBottom) {
      console.log("   ↳ Reached bottom of sidebar")
      break
    }

    // Wait for virtual scroll to render new items
    await page.waitForTimeout(500)
    totalScrolls++

    // Safety limit
    if (totalScrolls > 100) {
      console.log("   ⚠️  Reached maximum scroll limit")
      break
    }
  }

  // Build tree structure from collected items
  console.log(`\n   ✅ Collected ${allItems.size} unique navigation items`)
  return buildTreeFromFlatItems(Array.from(allItems.values()))
}

async function expandVisibleSections(page) {
  const expanded = await page.evaluate(() => {
    let count = 0
    const expandables = document.querySelectorAll(".navigator-card-item")

    expandables.forEach((item) => {
      // Check if this item has an expandable chevron
      const chevron = item.querySelector("svg.inline-chevron-right-icon")
      if (!chevron || item.offsetHeight === 0) return

      // Get the title to check what we're expanding
      const titleElement = item.querySelector(".highlight") || item.querySelector("h3") || item
      const title = titleElement.textContent?.trim() || ""

      // Skip if this is the "All Technologies" button or similar navigation
      if (title.includes("All Technologies")) return

      // Only expand if this is a SwiftUI-related section
      const isSwiftUISection =
        item.classList.contains("is-group") && !item.querySelector('a[href*="/documentation/"][href*="/"]')

      if (isSwiftUISection) {
        const clickTarget = item.querySelector(".head-wrapper") || item
        clickTarget.click()
        count++
      }
    })

    return count
  })

  if (expanded > 0) {
    await page.waitForTimeout(300) // Wait for expansions to complete
  }

  return expanded
}

async function extractVisibleItems(page) {
  return await page.evaluate(() => {
    const items = []
    const navItems = document.querySelectorAll(".navigator-card-item")

    navItems.forEach((navItem) => {
      // Only process items that are actually visible (have height)
      if (navItem.offsetHeight === 0) return

      const linkElement = navItem.querySelector("a") || navItem.querySelector("h3")
      if (!linkElement) return

      const titleElement = linkElement.querySelector(".highlight") || linkElement
      const title = titleElement.textContent.trim()

      let url = ""
      if (linkElement.tagName === "A") {
        url = linkElement.href
      } else {
        const titleSlug = title.toLowerCase().replace(/\s+/g, "-")
        url = `https://developer.apple.com/documentation/swiftui#${titleSlug}`
      }

      // Skip items that are not SwiftUI related
      // Look for items that are either SwiftUI sections or have SwiftUI in the URL
      const isSwiftUIRelated =
        url.includes("/swiftui") ||
        url.includes("swiftui#") ||
        navItem.closest('[technologypath="/documentation/swiftui"]') !== null ||
        title === "SwiftUI" ||
        !url.includes("/documentation/") || // Include group headers without specific docs
        navItem.classList.contains("is-group")

      if (!isSwiftUIRelated && url.includes("/documentation/") && !url.includes("/swiftui")) {
        return // Skip non-SwiftUI documentation items
      }

      // Get nesting level
      const nestingIndex = navItem.getAttribute("data-nesting-index")
      const level = nestingIndex ? parseInt(nestingIndex, 10) : 0

      items.push({
        title: title,
        url: url,
        level: level,
        isGroup: navItem.classList.contains("is-group"),
      })
    })

    return items
  })
}

function buildTreeFromFlatItems(items) {
  const root = {
    title: "SwiftUI",
    url: "https://developer.apple.com/documentation/swiftui",
    children: [],
  }

  if (items.length === 0) return root

  // Create a stack to track parent nodes at each level
  const stack = [root]
  let lastLevel = -1

  items.forEach((item) => {
    const node = {
      title: item.title,
      url: item.url,
      children: [],
    }

    // Adjust stack to find the correct parent
    while (stack.length > item.level + 1) {
      stack.pop()
    }

    // Add node to its parent
    const parent = stack[stack.length - 1]
    parent.children.push(node)

    // Add this node to stack if it's a group (can have children)
    if (item.isGroup) {
      stack.push(node)
    }

    lastLevel = item.level
  })

  return root
}

async function scrollSidebar(page) {
  // Find the scrollable container - look for the vue-recycle-scroller
  const scrollContainer = await page.$(".vue-recycle-scroller")
  if (!scrollContainer) {
    // Try alternative selector for the sidebar content area
    const altContainer = await page.$("nav.navigator .card-body")
    if (!altContainer) {
      console.log("   ⚠️  Could not find scrollable container")
      return
    }
  }

  let previousHeight = 0
  let currentHeight = 0
  let scrollAttempts = 0
  const maxScrollAttempts = 50 // Prevent infinite loops

  // Keep scrolling until we reach the bottom
  while (scrollAttempts < maxScrollAttempts) {
    // Get current scroll height and position
    const scrollInfo = await page.evaluate(() => {
      const scroller =
        document.querySelector(".vue-recycle-scroller") || document.querySelector("nav.navigator .card-body")
      if (scroller) {
        return {
          scrollHeight: scroller.scrollHeight,
          scrollTop: scroller.scrollTop,
          clientHeight: scroller.clientHeight,
          selector: scroller.className,
        }
      }
      return { scrollHeight: 0, scrollTop: 0, clientHeight: 0, selector: "not found" }
    })

    currentHeight = scrollInfo.scrollHeight

    if (scrollAttempts === 0) {
      console.log(`   ↳ Found scrollable container: .${scrollInfo.selector}`)
      console.log(`   ↳ Initial scroll height: ${scrollInfo.scrollHeight}px`)
    }

    // If height hasn't changed, we might be at the bottom
    if (currentHeight === previousHeight) {
      // Try one more scroll to be sure
      await page.evaluate(() => {
        const scroller =
          document.querySelector(".vue-recycle-scroller") || document.querySelector("nav.navigator .card-body")
        if (scroller) {
          scroller.scrollTop = scroller.scrollHeight
        }
      })

      await page.waitForTimeout(500)

      // Check height again
      const finalHeight = await page.evaluate(() => {
        const scroller =
          document.querySelector(".vue-recycle-scroller") || document.querySelector("nav.navigator .card-body")
        return scroller ? scroller.scrollHeight : 0
      })

      if (finalHeight === currentHeight) {
        console.log(`   ↳ Reached bottom after ${scrollAttempts} scrolls`)
        break
      }
    }

    // Scroll to bottom
    await page.evaluate(() => {
      const scroller =
        document.querySelector(".vue-recycle-scroller") || document.querySelector("nav.navigator .card-body")
      if (scroller) {
        scroller.scrollTop = scroller.scrollHeight
      }
    })

    // Wait for content to load
    await page.waitForTimeout(300)

    previousHeight = currentHeight
    scrollAttempts++

    // Show progress every 10 scrolls
    if (scrollAttempts % 10 === 0) {
      console.log(`   ↳ Scrolling... (${scrollAttempts} times)`)
    }
  }

  if (scrollAttempts >= maxScrollAttempts) {
    console.log(`   ⚠️  Reached maximum scroll attempts (${maxScrollAttempts})`)
  }

  // Scroll back to top to ensure all content is accessible
  await page.evaluate(() => {
    const scroller =
      document.querySelector(".vue-recycle-scroller") || document.querySelector("nav.navigator .card-body")
    if (scroller) {
      scroller.scrollTop = 0
    }
  })

  // Wait a bit for the UI to settle
  await page.waitForTimeout(500)
}

async function expandAllSections(page) {
  let expansionsCount = 0
  let previousCount = -1

  // Keep clicking disclosure buttons until no new ones appear
  while (expansionsCount !== previousCount) {
    previousCount = expansionsCount

    // Find all expandable items - look for items with chevrons that are not expanded
    const expandableItems = await page.evaluate(() => {
      const items = []
      // Look for all clickable elements with chevrons
      const possibleExpandables = document.querySelectorAll('button, [role="button"], .head-wrapper, h3')

      possibleExpandables.forEach((element, index) => {
        // Check if this element or its children contain a chevron
        const chevron =
          element.querySelector("svg") || (element.parentElement && element.parentElement.querySelector("svg"))
        if (chevron) {
          // Check if the chevron is a right-pointing arrow (collapsed state)
          const pathData = chevron.querySelector("path")?.getAttribute("d") || ""
          const isRightChevron =
            pathData.includes("4.81347656") ||
            chevron.classList.contains("inline-chevron-right-icon") ||
            chevron.getAttribute("aria-label")?.includes("chevron")

          if (isRightChevron) {
            // Store the selector that can be used to click this element
            items.push({
              index: index,
              selector:
                element.tagName.toLowerCase() +
                (element.id ? `#${element.id}` : "") +
                (element.className ? `.${element.className.split(" ").join(".")}` : ""),
            })
          }
        }
      })
      return items
    })

    // Click each expandable item
    for (const item of expandableItems) {
      try {
        await page.evaluate((itemData) => {
          const possibleExpandables = document.querySelectorAll('button, [role="button"], .head-wrapper, h3')
          const element = possibleExpandables[itemData.index]
          if (element) {
            element.click()
          }
        }, item)

        await page.waitForTimeout(200) // Small delay between clicks
        expansionsCount++
      } catch (e) {
        // Item might have been removed or changed, continue
        continue
      }
    }

    // Wait for any new content to load
    await page.waitForTimeout(500)
  }

  console.log(`   ↳ Expanded ${expansionsCount} sections`)

  // Debug: Log current state of navigation items
  const itemCount = await page.evaluate(() => {
    return document.querySelectorAll(".navigator-card-item").length
  })
  console.log(`   ↳ Total navigation items visible: ${itemCount}`)
}

async function extractNavigationStructure(page) {
  // Main extraction logic executed in the browser context
  const structure = await page.evaluate(() => {
    // Helper function to get the nesting level from the element
    function getNestingLevel(element) {
      const nestingIndex = element.getAttribute("data-nesting-index")
      return nestingIndex ? parseInt(nestingIndex, 10) : 0
    }

    // Helper function to build tree from flat list
    function buildTree(items) {
      const root = {
        title: "SwiftUI",
        url: "https://developer.apple.com/documentation/swiftui",
        children: [],
      }

      const stack = [root]
      let lastLevel = -1

      for (const item of items) {
        const level = item.level

        // Pop stack until we find the right parent
        while (stack.length > level + 1) {
          stack.pop()
        }

        // Add to current parent
        const parent = stack[stack.length - 1]
        parent.children.push(item.node)

        // Push this item to stack if it might have children
        stack.push(item.node)
        lastLevel = level
      }

      return root
    }

    // Find the navigator
    const navigator = document.querySelector("nav.navigator")
    if (!navigator) return null

    // Get all navigator items
    const navItems = navigator.querySelectorAll(".navigator-card-item")
    const items = []

    navItems.forEach((navItem) => {
      // Skip items that are truly hidden (not just virtually scrolled)
      if (navItem.style.display === "none") {
        return
      }

      // Get the link element
      const linkElement = navItem.querySelector("a") || navItem.querySelector("h3")
      if (!linkElement) return

      // Extract title and URL
      const titleElement = linkElement.querySelector(".highlight") || linkElement
      const title = titleElement.textContent.trim()

      // Get URL from the link
      let url = ""
      if (linkElement.tagName === "A") {
        url = linkElement.href
      } else {
        // For group headers, construct URL from title
        const titleSlug = title.toLowerCase().replace(/\s+/g, "-")
        url = `https://developer.apple.com/documentation/swiftui#${titleSlug}`
      }

      // Get nesting level
      const level = getNestingLevel(navItem)

      // Check if it's a group (has 'is-group' class)
      const isGroup = navItem.classList.contains("is-group")

      items.push({
        level: level,
        node: {
          title: title,
          url: url,
          children: [],
        },
      })
    })

    // Build tree structure from flat list
    return buildTree(items)
  })

  return structure
}

function countItems(node) {
  if (!node) return 0
  let count = 1 // Count the current node

  if (node.children && Array.isArray(node.children)) {
    for (const child of node.children) {
      count += countItems(child)
    }
  }

  return count
}

// Run the scraper
scrapeSwiftUIDocs()
  .then(() => {
    console.log("\n🎉 Scraping completed successfully!")
    process.exit(0)
  })
  .catch((error) => {
    console.error("\n💥 Scraping failed:", error)
    process.exit(1)
  })
