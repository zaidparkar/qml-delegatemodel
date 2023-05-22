import QtQuick
import ModelClass

Window {
    id: root
    visible: true

    property var currentPage: page1;
    property string currentID: ""
    property string currentName: ""
    property string currentNumber: ""

    function navigateTo(page) {
        nameTextInput.focus = false;
        numberTextInput.focus = false;

        currentPage.visible = false;
        currentPage = page
        currentPage.visible = true
    }

    function getRandomColor() {
        var letters = "0123456789ABCDEF";
        var color = "#";
        for (var i = 0; i < 6; i++) {
            color += letters[Math.floor(Math.random() * 16)];
        }
        return color;
    }

    Item {
        id: page1
        anchors{fill: parent;margins: 15}

        Rectangle {

            id: appName
            width: parent.width
            height: 30

            Text {
                anchors{centerIn: parent}
                font{pixelSize: 20;bold:true}
                text: "Contacts App"
            }
        }

        ListView {
            id: list
            width: parent.width
            height: parent.height - 30
            anchors{top: appName.bottom; topMargin: 10}
            clip: true
            spacing: 4

            Component {
                id: sectionDelegate
                Rectangle {
                    width: 5
                    height: 18

                    Text {
                        font.pixelSize: 12
                        text: section.toUpperCase()
                    }
                }
            }

            section.property: "name"
            section.criteria: ViewSection.FirstCharacter
            section.delegate: sectionDelegate

            Component {
                id: tasksDelegate

                Item{
                    id: itemWrapper
                    width: list.width
                    height: 35

                    Row {
                        spacing: 20

                        Rectangle {
                            width: 35
                            height: itemWrapper.height
                            color: getRandomColor()
                            radius: width/2

                            Text {
                                anchors{centerIn: parent}
                                font{pixelSize: 16}
                                color: "white"
                                text: model.name.charAt(0).toUpperCase()
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
                            currentID = model.id
                            currentName = model.name
                            currentNumber = model.number
                            page1.visible = false
                            page2.y = 0
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

            ContactClass {
                id: mymodel
            }

            model: mymodel

            delegate: tasksDelegate
        }

        Rectangle {
            id: getButton
            width: 200
            height: 60
            anchors{top: list.bottom; horizontalCenter: parent.horizontalCenter; topMargin: 10}
            border {
                width: 1
                color: "black"
            }
            Text {
                anchors{centerIn: parent}
                text: qsTr("Sync Contacts")
            }
            MouseArea  {
                anchors.fill: parent
                onClicked: {
                    mymodel.getContacts();
                }
            }
        }
    }

    Item {
        id: page2
        width: root.width
        height: root.height
        visible: false
        y: root.height

        Column {
            id: allElementsPage2
            spacing: 30
            anchors{centerIn: parent}

            Rectangle{
                id: name
                width: 200
                height: 50
                border{width: 1}
                TextInput {
                    id: nameTextInput
                    text: currentName
                    anchors{centerIn: parent}
                    font{pixelSize: 18}
                }
            }

            Rectangle {
                id: number
                width: 200
                height: 50
                border{width: 1}
                TextInput {
                    id: numberTextInput
                    text: currentNumber
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    anchors{centerIn: parent}
                    font{pixelSize: 18}
                }
            }

            Rectangle {
                width: 200
                height: 60
                anchors{topMargin: 10}
                border {
                    width: 1
                    color: "black"
                }
                Text {
                    anchors{centerIn: parent}
                    text: qsTr("Update Contact")
                }
                MouseArea  {
                    anchors.fill: parent
                    onClicked: {
                        mymodel.modifyContact(currentID.toString(),nameTextInput.text.toString(),numberTextInput.text.toString())
                        mymodel.getContacts()
                        root.navigateTo(page1)
                    }
                }
            }

            Rectangle {
                width: 200
                height: 60
                anchors{topMargin: 10}
                border {
                    width: 1
                    color: "black"
                }
                Text {
                    anchors{centerIn: parent}
                    text: qsTr("Delete Contact")
                }
                MouseArea  {
                    anchors.fill: parent
                    onClicked: {
                        mymodel.deleteContact(currentID.toString())
                        mymodel.getContacts()
                        root.navigateTo(page1)
                    }
                }
            }

            Rectangle {
                width: 200
                height: 60
                anchors{topMargin: 10}
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
                        page2.y = root.height
                        page1.visible = true
                    }
                }
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 200
            }
        }

    }

    Component.onCompleted: {
        mymodel.getContacts()
        getButton.visible = false
    }
}


