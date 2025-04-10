import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: mainMenu
    required property StackView stackView
    required property ApplicationWindow mainWindow
    width: parent.width
    height: parent.height

    Image {
        anchors.fill: parent
        //source: "path/to/your/image.jpg"  // Replace with your image path
        fillMode: Image.PreserveAspectFit  // This will crop the image to fill while maintaining aspect ratio
    }
}