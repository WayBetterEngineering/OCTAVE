import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import QtQuick3D.AssetUtils
import "." as App

Item {
    id: carMenu
    width: parent.width
    height: parent.height
    
    // Required properties
    required property var stackView
    property var mainWindow
    
    // Debugging output
    Component.onCompleted: {
        console.log("CarMenu component created successfully")
    }

    // Background with accent color
    Rectangle {
        anchors.fill: parent
        color: App.Style.accent
        
        
        // 3D View container
        Rectangle {
            id: modelContainer
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: App.Spacing.overallMargin
            }
            color: "black"
            
            View3D {
                id: view3d
                anchors.fill: parent
                
                environment: SceneEnvironment {
                    clearColor: "lightblue"
                    backgroundMode: SceneEnvironment.Color
                    antialiasingMode: SceneEnvironment.MSAA
                    antialiasingQuality: SceneEnvironment.Medium
                    aoStrength: 0
                }
                
                PerspectiveCamera {
                    id: camera
                    position: Qt.vector3d(0, 40, 100)
                    eulerRotation.x: -15
                    clipNear: 10
                    clipFar: 1000
                }
                
                // Main light - made to feel "larger"
                PointLight {
                    id: mainLight
                    position: Qt.vector3d(0, 250, 50)
                    brightness: 7
                    ambientColor: "#FFFFFF"
                    castsShadow: true
                    shadowBias: 0.005
                    shadowFactor: 50  // Reduced for softer shadows
                    shadowFilter: 50  // Higher filter value for softer shadows
                    quadraticFade: 0.5  // Reduced falloff to simulate larger light
                }
                
                // Fill light - also with reduced falloff
                PointLight {
                    id: fillLight
                    position: Qt.vector3d(-50, 100, 150)
                    brightness: 8  // Increased slightly
                    ambientColor: "#FFFFEE"
                    castsShadow: false
                    quadraticFade: 0.3  // Very low falloff to simulate large area light
                }
                
                Node {
                    id: jeepNode
                    scale: Qt.vector3d(30, 30, 30)
                    RuntimeLoader {
                        id: modelLoader
                        source: "./assets/cam.glb"
                        onStatusChanged: {
                            console.log("Model status:", status, statusString)
                        }
                    }
                }
            }
            
            // Error message text overlay
            Text {
                id: errorText
                anchors.centerIn: parent
                color: "red"
                font.pixelSize: 24
                visible: false
                text: ""
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                property real lastX: 0
                property real lastY: 0
                property bool dragging: false

                onPressed: (event) => {
                    lastX = event.x
                    lastY = event.y
                    dragging = true
                }

                onReleased: (event) => {
                    dragging = false
                }

                onPositionChanged: (event) => {
                    if (!dragging)
                        return

                    let dx = event.x - lastX
                    let dy = event.y - lastY

                    // Horizontal drag rotates around Y-axis
                    jeepNode.eulerRotation.y += dx * 0.5

                    // Vertical drag rotates around X-axis (clamped between -90 and 90)
                    jeepNode.eulerRotation.x = Math.max(-90, Math.min(90, jeepNode.eulerRotation.x + dy * 0.5))

                    lastX = event.x
                    lastY = event.y
                }
            }
        }
    }
}