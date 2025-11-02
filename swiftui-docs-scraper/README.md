# SwiftUI Documentation Sidebar Scraper

A Node.js tool that scrapes Apple's SwiftUI documentation sidebar navigation and outputs it as a nested JSON structure. This data can be used to render your own native sidebar navigation.

## Features

- 🚀 Automated navigation extraction from Apple Developer Documentation
- 📂 Expands all collapsible sections automatically
- 🌳 Preserves the hierarchical structure of the documentation
- 📊 Outputs clean, nested JSON ready for use in your applications
- ⚡ Built with Playwright for reliable browser automation

## Prerequisites

- Node.js (v16 or higher)
- pnpm package manager

## Installation

1. Clone or copy the project:
```bash
cd /path/to/swiftui-docs-scraper
```

2. Install dependencies using pnpm:
```bash
pnpm install
```

## Usage

Run the scraper:
```bash
pnpm run scrape
```

The script will:
1. Launch a headless browser
2. Navigate to the SwiftUI documentation
3. Expand all collapsible sections in the sidebar
4. Extract the navigation structure
5. Save the results to `output/swiftui-sidebar.json`

## Output Format

The scraper produces a nested JSON structure like this:

```json
{
  "title": "SwiftUI",
  "url": "https://developer.apple.com/documentation/swiftui",
  "children": [
    {
      "title": "Essentials",
      "url": "https://developer.apple.com/documentation/swiftui#essentials",
      "children": []
    },
    {
      "title": "App organization",
      "url": "https://developer.apple.com/documentation/swiftui/app-organization",
      "children": [
        {
          "title": "App",
          "url": "https://developer.apple.com/documentation/swiftui/app",
          "children": []
        }
      ]
    }
  ]
}
```

Each navigation item contains:
- `title`: The display name of the navigation item
- `url`: The full URL to the documentation page
- `children`: An array of nested navigation items

## Configuration

To modify the scraper behavior, edit `scrapeSwiftUIDocs.js`:

- **Headless mode**: Change `headless: true` to `false` to see the browser
- **Timeout settings**: Adjust timeout values for slower connections
- **Debug mode**: Add `slowMo: 100` to the browser launch options

## Limitations

- The scraper depends on Apple's documentation HTML structure. Changes to their site may require updates to the selectors
- Currently only scrapes the visible navigation items after expanding sections
- May take some time to complete depending on the number of sections to expand

## Troubleshooting

### Timeout errors
If you get timeout errors, try:
1. Increasing the timeout values in the script
2. Running with a visible browser to debug: `headless: false`
3. Checking your internet connection

### Missing navigation items
The documentation may load dynamically. The script waits for sections to expand, but you can:
1. Increase the wait time after expansions
2. Add more specific selectors for deeply nested items

## Development

### Project Structure
```
swiftui-docs-scraper/
├── scrapeSwiftUIDocs.js    # Main scraper script
├── output/                 # Output directory
│   └── swiftui-sidebar.json
├── package.json
├── pnpm-lock.yaml
├── .gitignore
└── README.md
```

### Adding Features

To extend the scraper to capture additional metadata:

1. Modify the `extractItem` function in `extractNavigationStructure`
2. Add new fields to the item object (e.g., `type`, `description`, `availability`)
3. Update the extraction logic to find and parse the new data

## License

This project is provided as-is for educational and development purposes. Please respect Apple's terms of service when using their documentation.


