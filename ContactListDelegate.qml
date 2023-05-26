import QtQuick

Item {
    id: contactListDelegate

    Item{
        id: itemWrapper
        width: list.width
        height: 35

        Row {
            spacing: 20
            Rectangle {
                id: imageWrapper
                width: 35
                height: itemWrapper.height
                radius: width/2
                clip: true

                Image {
                    anchors{fill: parent; centerIn: parent}
                    source: "assets:/cat.jpeg"
                }
            }

            Rectangle {
                width: theNameOfContact.contentWidth
                height: itemWrapper.height

                Text {
                    id: theNameOfContact
                    text: model.name
                    font.pixelSize: 18
                    anchors{verticalCenter: parent.verticalCenter}
                }
            }

        }
        MouseArea {
            id: contactPageMouseArea
            anchors{fill: parent}
            onClicked: {
                root.currentID = model.id
                root.currentName = model.name
                root.currentNumber = model.number

                var pos = imageWrapper.mapFromItem(root,0,0)
                root.initialX = Math.abs(pos.x)
                root.initialY = Math.abs(pos.y)
                root.initialWidth = imageWrapper.width;
                root.initialHeight = imageWrapper.height;
                root.scaleFactor = root.width / imageWrapper.width;
                page1.opacity = 0
                root.animating = true
                root.navigateTo(page2)
            }
        }

        Rectangle {
            id: effectWrapper

            anchors{fill: parent}
            radius: width/2
            color: contactPageMouseArea.containsMouse ? "lightgray" : "transparent"
            opacity: contactPageMouseArea.containsMouse ? 0.5 : 1.0

            states: [
                State {
                    name: "pressed"
                    when: contactPageMouseArea.pressed
                    PropertyChanges { target: effectWrapper; color: "gray" }
                }
            ]

            transitions: Transition {
                PropertyAnimation { target: effectWrapper; properties: "color"; duration: 200 }
            }
        }

    }

}
