import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.mitakuuluu2.client 1.0
import "Utilities.js" as Utilities

Dialog {
    id: page
    objectName: "selectContact"
    canAccept: false

    property string jid: ""
    property variant jids: []
    property bool multiple: false
    property bool noGroups: false

    signal added(string pjid)
    signal removed(string pjid)

    property ListModel selected
    onSelectedChanged: select(jids)
    function select(participants) {
        for (var i = 0; i < participants.count; i ++) {
            var model = participants.get(i)
            var value = page.jids
            value.splice(0, 0, model.jid)
            page.jids = value
        }
    }

    onStatusChanged: {
        if(status === DialogStatus.Closed) {
            page.jids = []
            page.jid = ""
        }
        else if (status === DialogStatus.Opened) {
            page.canAccept = false
        }
    }

    DialogHeader {
        id: title
        title: jids.length == 0 ? qsTr("Select contacts", "Select contact page title")
                                : qsTr("Selected %n contacts", "Select contact page title", jids.length)
    }

    SilicaListView {
        id: listView
        anchors.fill: page
        anchors.topMargin: title.height + Theme.paddingSmall
        model: contactsModel
        delegate: contactsDelegate
        clip: true
        section.property: "nickname"
        section.criteria: ViewSection.FirstCharacter

        FastScroll {
            id: fastScroll
            listView: listView
            __hasPageHeight: false
        }
    }

    ContactsFilterModel {
        id: contactsModel
        contactsModel: ContactsBaseModel
        hideGroups: noGroups
    }

    Component {
        id: contactsDelegate

        BackgroundItem {
            id: item
            width: parent.width
            height: Theme.itemSizeMedium
            highlighted: down || checked
            property bool checked: page.jids.indexOf(model.jid) != -1

            AvatarHolder {
                id: ava
                width: Theme.iconSizeLarge
                height: Theme.iconSizeLarge
                source: model.avatar
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                id: nickname
                font.pixelSize: Theme.fontSizeMedium
                text: Utilities.emojify(model.nickname, emojiPath)
                anchors.left: ava.right
                anchors.leftMargin: 16
                anchors.top: parent.top
                anchors.topMargin: Theme.paddingSmall
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                wrapMode: Text.NoWrap
                color: item.highlighted ? Theme.highlightColor : Theme.primaryColor
                truncationMode: TruncationMode.Fade
            }

            Label {
                id: status
                font.pixelSize: Theme.fontSizeSmall
                text: model.jid.indexOf("-") > 0 ? qsTr("Group chat", "Contacts group page text in status message line") : Utilities.emojify(model.message, emojiPath)
                anchors.left: ava.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.paddingSmall
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                wrapMode: Text.NoWrap
                color: item.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                truncationMode: TruncationMode.Fade
            }

            onClicked: {
                if (page.jids.length > 1 && model.jid.indexOf("-") == -1 && page.jids[0].indexOf("-") == -1) {
                    selectMany(model.jid)
                }
                else {
                    selectOne(model.jid)
                }
            }
            onPressAndHold: {
                if (multiple && model.jid.indexOf("-") == -1 && page.jids[0].indexOf("-") == -1) {
                    selectMany(model.jid)
                }
                else {
                    selectOne(model.jid)
                }
            }

            function selectMany(jid) {
                var value = page.jids
                var exists = value.indexOf(jid)
                if (exists != -1) {
                    value.splice(exists, 1)
                    page.removed(jid)
                }
                else {
                    value.splice(0, 0, jid)
                    page.added(jid)
                }
                page.jids = value
                page.canAccept = page.jids.length > 0
            }

            function selectOne(jid) {
                page.jids = [model.jid]
                page.canAccept = page.jids.length > 0
            }
        }
    }
}