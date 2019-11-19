# Notes app

Simple desktop application to store, create and delete notes

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

For building from source we need any application that can bundles a Python application and all its dependencies into a single package.
I'll show on example with [PyInstaller](https://www.pyinstaller.org/):

1. Install PyInstaller: `pip install pyinstaller`

### Installing

2. Generate main *.spec* file: `pyinstaller -F --noconsole notes_spec.py`

3. Open generated *.spec* file

4. Add into *Analysis* next files: *notes.py, resource_rc.py, strings.py, qml_resource.py*

5. Generate QML *.spec* file from *qml_resource.qrc*: `pyrcc5 -o qml_resource.py qml_resource.qrc`

6. Generate configuration *.spec* file from *qml_resource.qrc*: `pyrcc5 -o resource_rc.py resource.qrc`

7. Bundle the files: `pyinstaller notes_spec.spec`

8. After bundeling single package is in folder */dist/* 

## Built With

* [PyQt5](https://www.riverbankcomputing.com/static/Docs/PyQt5/) - is a Python binding of the cross-platform GUI toolkit Qt, implemented as a Python plug-in.


## Authors

* **Andrey Mikhalev** - *Initial work* - [evilixy](https://github.com/evilixy)

## License

This project is licensed under the GPL - see the [LICENSE.md](LICENSE.md) file for details

