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

//ParentChange
//Package,DelegateModel

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
            height: parent.height - 30 //(getButton.height + 40)
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
                            radius: width/2
                            clip: true

                            Image {
                                id: img
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

            ListView {

                Component {
                    id: listDelegate
                    Rectangle{
                        id: name
                        width: 200
                        height: 50
                        Text {
                            id: nameTextInput
                            text: currentName
                            anchors{centerIn: parent}
                            font{pixelSize: 18}
                        }
                    }
                }




            }



            Rectangle {
                id: number
                width: 200
                height: 50
                Text {
                    id: numberTextInput
                    text: currentNumber
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
                    text: qsTr("Go Back")
                }
                MouseArea  {
                    anchors.fill: parent
                    onClicked: {
                        page2.y = root.height
                        currentPage = page1
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

        contentItem.Keys.released.connect(function(event) {
            if (event.key === Qt.Key_Back) {
                event.accepted = true
                if(currentPage == page2) {
                    page2.y = root.height
                    currentPage = page1
                    page1.visible = true
                }
            }
        })
    }
}


