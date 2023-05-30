import QtQuick

Package {

    Item{
        Package.name: "fullList"
        id: itemWrapper
        width: root.width
        height: 35

        Row {
            id:row
            spacing: 20
        }

        MouseArea {
            id: contactPageMouseArea
            anchors{fill: parent}
            onClicked: {
                contactPageWrapper.ListView.view.currentIndex = index
                if(root.state == "inFullList") {
                    root.state = "inContact"
                }
            }
        }
        Rectangle {
            id: effectWrapper

            anchors{fill: itemWrapper}
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



        states: [
            State {
                name: "inFullList"
                when: root.state == "inFullList"

                ParentChange {target: imageDP; parent: row}
                ParentChange {target: nameLabel; parent: row}
                ParentChange {target: numberLabel; parent: row}
                ParentChange {target: backButton; parent: row}

                PropertyChanges {target: imageDP; width: 35; height: itemWrapper.height}
                PropertyChanges {target: nameLabel; width: theNameOfContact.contentWidth; height: itemWrapper.height}
                PropertyChanges {target: numberLabel; visible:false}
                PropertyChanges {target: backButton; visible: false}
            },

            State {
                name:"inContact"
                when: root.state == "inContact" && contactPageWrapper.ListView.view.currentIndex===index

                ParentChange {target: imageDP; parent: contactColumn; width: root.width; height: root.width;x: 0; y:0}
                ParentChange {target: nameLabel; parent: contactColumn; width: 200; height: 50;x:0;y: 140}
                ParentChange {target: numberLabel; parent: contactColumn; width: 200; height: 50;x:0;y: 200}
                ParentChange {target: backButton; parent: contactColumn}

                PropertyChanges {target: imageDP;}
                PropertyChanges {target: nameLabel; width: 200; height: 100}
                PropertyChanges {target: numberLabel;visible: true}
                PropertyChanges {target: backButton; visible: true}

            }

        ]

        transitions: [
            Transition {
                ParentAnimation {
                    NumberAnimation {
                        properties: "x,y,width,height,opacity"
                        duration: 1000
                        easing.type: Easing.OutQuart
                    }
                }
            }
        ]
    }

    Item {
        Package.name: "contact"
        id: contactPageWrapper
        width: applicationWindow.width
        height: applicationWindow.height

        Column {
            id: contactColumn
            width: root.width
            spacing: 20
            anchors{centerIn: parent}
        }
    }

/****************************************************************/


    Rectangle {
        id: imageDP
        width: itemWrapper.height
        height: itemWrapper.height
        clip: true

        Image {
            anchors{fill: parent}
            source: "assets:/cat.jpeg"
        }
    }

    Rectangle {
        id: nameLabel
        width: theNameOfContact.contentWidth
        height: itemWrapper.height

        Text {
            id: theNameOfContact
            text: name
            font.pixelSize: 18
        }

    }

    Rectangle {
        id: numberLabel
        width: 200
        height: 100
        visible: false
        Text {
            id: numberTextInput
            text: number
            font{pixelSize: 18}
        }
    }

    Rectangle {
        id: backButton
        width: 200
        height: 60
        visible: false
        border {
            width: 1
            color: "black"
        }
        Text {
            anchors{centerIn: parent}
            text: qsTr("Go Back")
        }
        MouseArea  {
            anchors.fill: parent
            onClicked: {
                contactPageWrapper.ListView.view.currentIndex = index;
                root.state = "inFullList"
            }
        }
    }


}
