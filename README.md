# Made With Godot Widget

## Data Source
This plugin fetches developer showcase data from a remote file hosted on GitHub. The data includes developer names, project information, images, and URLs. Users can contribute their own data sets by forking the data repository and submitting a pull request (PR) with their additions or changes.

- **Data repository:** [https://github.com/Saturn91/made-with-godot-data](https://github.com/Saturn91/made-with-godot-data)
- To add your own data, fork the repository above, add your entry, and open a PR.

## Plugin Functionality
This Godot addon provides a widget that displays a list of developers and their Godot projects, including:
- Developer name and project title
- Project image (fetched remotely)
- Project URL
- A QR code for the project URL (supports all valid URL characters)

The widget fetches and updates data at runtime, ensuring the latest information is always displayed. The QR code is generated in byte mode for full compatibility with all URLs.

## Installation
1. Copy the `addons/made_with_godot/` folder into your Godot project's `addons/` directory.
2. Enable the plugin in **Project > Project Settings > Plugins**.

## Usage
- Add the `MadeWithGodotWidget` node to your scene.
- The widget will automatically fetch and display the latest developer/project data.

## Contributing
To add your own project or developer info, submit a PR to the [data repository](https://github.com/Saturn91/made-with-godot-data).

## License
MIT License
