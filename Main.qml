import QtQuick
import ModelClass

Window {
    id: root
    visible: true

    property var currentPage: page1;
    property string currentName: ""
    property string currentNumber: ""

    function navigateTo(page) {
        nameTextInput.focus = false;
        numberTextInput.focus = false;

        currentPage.visible = false;
        currentPage = page
        currentPage.visible = true
    }

    Item {
        id: page1
        anchors{fill: parent}
        ListView {
            id: list
            width: parent.width
            height: 350
            anchors{topMargin: 5;}
            clip: true
            spacing: 4

            Component {
                id: tasksDelegate
                Rectangle {
                    width: root.width
                    border{width: 1}
                    height: 30
                    Row {
                        spacing: 50
                        anchors.centerIn: parent

                        Text {
                            text: model.name
                            font.pixelSize: 14
                        }

                        Text {
                            text: model.number
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    MouseArea {
                        anchors{fill: parent}
                        onClicked: {
                            currentName = model.name
                            currentNumber = model.number
                            root.navigateTo(page2)
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
        anchors{fill: parent}
        visible: false

        Column {
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
                        root.navigateTo(page1)
                    }
                }
            }
        }
    }
}


