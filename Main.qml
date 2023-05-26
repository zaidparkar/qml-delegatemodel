import QtQuick
import ModelClass

Window {
    id: root
    visible: true

    property var currentPage: page1;
    property string currentID: ""
    property string currentName: ""
    property string currentNumber: ""

    //animation properties
    property int animationDuration: 3000
    property real initialX: 0
    property real initialY: 0
    property real initialWidth: 0
    property real initialHeight: 0
    property real scaleFactor: 1.0
    property bool animating: false


    function navigateTo(page) {

//        currentPage.visible = false;
        currentPage = page
        currentPage.visible = true
    }

    //ParentChange
    //Package,DelegateModel

    ContactClass {
        id: mymodel
    }

    DelegateModel {
        id: visualModel

        model: mymodel

        delegate: Package {
            ContactListDelegate {
                Package.name: "contactlist"

            }
        }
    }


    Item {
        id: page1
        opacity: 1
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
            width: root.width
            height: root.height - 30
            anchors{top: appName.bottom; topMargin: 10}
            clip: true
            spacing: 40

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

            model: visualModel.parts.contactlist
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animationDuration/2
            }
        }
    }

    Item {
        id: page2
        visible: false


        x: root.animating ? root.initialX : 0
        y: root.animating ? root.initialY : 0
        scale: root.scaleFactor
        width: 0
        height: 0

        states: [
            State {
                name: "default"
                PropertyChanges {
                    target: page2
                    x: root.initialX
                    y: root.initialY
                    width: 0
                    height: 0
                    visible: false
                    scale: 0
                }
                PropertyChanges {
                    target: page1
                    opacity: 1
                    visible: true
                }
            },

            State {
                name: "infopage"
//                when: currentPage == page2
                PropertyChanges {
                    target: page2
                    x: 0
                    y: 0
                    width: root.width
                    height: root.height
                    visible: true
                    scale: 1.0
                }
                PropertyChanges {
                    target: page1
                    opacity: 0
                    visible: true
                }
            }

        ]

        transitions: [
            Transition {
                from: "default"
                to: "infopage"
                enabled: false

                reversible: true

                ParallelAnimation {
                    PropertyAction {
                        target: page1
                        property: "opacity"
                        value: 0
                    }
                    NumberAnimation {
                        target: page2
                        property: "x"
                        duration: root.animationDuration
                        easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        target: page2
                        property: "y"
                        duration: root.animationDuration
                        easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        target: page2
                        property: "width"
                        duration: root.animationDuration
                        easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        target: page2
                        property: "height"
                        duration: root.animationDuration
                        easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        target: page2
                        property: "scale"
                        duration: root.animationDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }

        ]

        Column {
            id: allElementsPage2
            width: root.width
            spacing: 30
            anchors{centerIn: parent}

            Rectangle {
                id: imageDP
                width: root.width
                height: root.width

                Image {
                    anchors{fill:parent}
                    source: "assets:/cat.jpeg"
                }
            }

            /*Rectangle {
                id: name
                width: 200
                height: 50
                anchors{horizontalCenter: parent.horizontalCenter}
                Text {
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
                anchors{horizontalCenter: parent.horizontalCenter}
                Text {
                    id: numberTextInput
                    text: currentNumber
                    anchors{centerIn: parent}
                    font{pixelSize: 18}
                }
            }*/

            ListView {

            }

            Rectangle {
                width: 200
                height: 60
                anchors{topMargin: 10}
                anchors{horizontalCenter: parent.horizontalCenter}
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
                        page2.width = 0
                        page2.height = 0
                        page2.scale = 0
                        page1.opacity = 1
                        page2.visible = false
                        navigateTo(page1)

                    }
                }
            }
        }

        onVisibleChanged: {
            if(!page2.visible) {
                root.animating = false
            }
        }


        NumberAnimation on x {
            from: root.initialX
            to: 0
            duration: root.animationDuration
            easing.type: Easing.InOutQuad
            running: root.animating
        }

        NumberAnimation on y {
            from: root.initialY
            to: 0
            duration: root.animationDuration
            easing.type: Easing.InOutQuad
            running: root.animating
        }

        NumberAnimation on width {
            to: root.width
            duration: root.animationDuration
            easing.type: Easing.InOutQuad
            running: root.animating
        }

        NumberAnimation on height {
            to: root.height
            duration: root.animationDuration
            easing.type: Easing.InOutQuad
            running: root.animating
        }

        NumberAnimation on scale {
            to: 1.0
            duration: root.animationDuration
            easing.type: Easing.InOutQuad
            running: root.animating

        }

    }


    Component.onCompleted: {
        mymodel.getContacts()

        contentItem.Keys.released.connect(function(event) {
            if (event.key === Qt.Key_Back) {
                event.accepted = true
                if(currentPage == page2) {
                    page2.width = 0
                    page2.height = 0
                    page2.scale = 0
                    page1.opacity = 1
                    page2.visible = false
                    navigateTo(page1)
                }
            }
        })
    }
}


