# Made With Godot Widget


## Data Source
This plugin fetches developer showcase data from a remote file hosted on GitHub. The data includes developer names, project information, images, and URLs. Users can contribute their own data sets by forking the data repository and submitting a pull request (PR) with their additions or changes.

- **Data repository:** [https://github.com/Saturn91/made-with-godot-data](https://github.com/Saturn91/made-with-godot-data)
- To add your own data, fork the repository above, add your entry, and open a PR.
- Include a screenshot of the widget added to your main menu in your PR 

## Credits & Ease of Use
For ease of use, I copied the content of the [https://kenyoni-software.github.io/godot-addons/addons/qr_code/](https://kenyoni-software.github.io/godot-addons/addons/qr_code/) Godot QR code addon and adjusted it slightly for my needs. Please refer to their project for the original source and more details.

## Plugin Functionality
This Godot addon provides a widget that displays a list of developers and their Godot projects, including:
- Developer name and project title
- Project image (fetched remotely)
- Project URL
- A QR code for the project URL (supports all valid URL characters)

The widget fetches and updates data at runtime, ensuring the latest information is always displayed. The QR code is generated in byte mode for full compatibility with all URLs.

## Installation
1. Add the plugin
2. Enable the plugin in **Project > Project Settings > Plugins**.

## Usage in the Editor

1. Add a `MadeWithGodotSource` node to your scene:
	- Press `Ctrl + A` and search for "MadeWithGodotSource".
	- This node will fetch the required data from the remote repository.

2. Add a `MadeWithGodotWidget` node to your menu or canvas:
	- Press `Ctrl + A` and search for "MadeWithGodotWidget".
	- This is the visual widget that displays the developer/project info and QR code.

The widget will automatically fetch and display the latest developer/project data at runtime.

![alt text](example.png)

## Contributing
To add your own project or developer info, submit a PR to the [data repository](https://github.com/Saturn91/made-with-godot-data).

## License
MIT License
