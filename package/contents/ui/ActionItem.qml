/*
 *    Copyright 2016-2024 Christian Loosli <develop@fuchsnet.ch>
 *
 *    This library is free software; you can redistribute it and/or
 *    modify it under the terms of the GNU Lesser General Public
 *    License as published by the Free Software Foundation; either
 *    version 2.1 of the License, or (at your option) version 3, or any
 *    later version accepted by the original Author.
 *
 *    This library is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    Lesser General Public License for more details.
 *
 *    You should have received a copy of the GNU Lesser General Public
 *    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */


import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

import "../code/hue.js" as Hue

Item {
    id: actionItem

    property int baseHeight : 40
    property string defaultIcon : "help-about"
    required property string actionTitle
    required property string actionSubtitle
    required property string actionIconName
    required property var actionPayloads

    width: ListView.view ? ListView.view.width : 0
    height: actionItemBase.height

    Item {
        id: actionItemBase


        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: -Math.round(Kirigami.Units.gridUnit / 3)
        }

        height: Math.max(Kirigami.Units.iconSizes.medium,
                         actionLabel.implicitHeight + actionInfoLabel.implicitHeight + Kirigami.Units.smallSpacing)
                + Math.round(Kirigami.Units.gridUnit / 2)

        Image {
            id: actionIcon

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }

            height: Kirigami.Units.iconSizes.medium
            width: height
            source: Qt.resolvedUrl("../images/" + (actionIconName || defaultIcon))
            fillMode: Image.PreserveAspectFit
        }

        PlasmaComponents.Label {
            id: actionLabel

            anchors {
                top: parent.top
                topMargin: Kirigami.Units.smallSpacing
                left: actionIcon.right
                leftMargin: Math.round(Kirigami.Units.gridUnit / 2)
                right: executeButton.visible ? executeButton.left : parent.right
                rightMargin: Kirigami.Units.smallSpacing
            }

            height: implicitHeight
            elide: Text.ElideRight
            font.weight: Font.Normal
            text: actionTitle
            textFormat: Text.PlainText
        }

        PlasmaComponents.Label {
            id: actionInfoLabel

            anchors {
                left: actionIcon.right
                leftMargin: Math.round(Kirigami.Units.gridUnit / 2)
                top: actionLabel.bottom
                topMargin: Kirigami.Units.smallSpacing
            }

            height: implicitHeight
            elide: Text.ElideRight
            //TODO: PortMe font.pointSize: theme.smallestFont.pointSize
            opacity: 0.6
            text: actionSubtitle
            textFormat: Text.PlainText
        }

        PC3.Button {
            id: executeButton

            anchors {
                right: parent.right
                rightMargin: Math.round(Kirigami.Units.gridUnit / 2)
                verticalCenter: actionIcon.verticalCenter
            }

            width: Kirigami.Units.gridUnit * 3
            height: Kirigami.Units.gridUnit * 2
            text: i18n("Run")
            onClicked: execute()
        }

    }

    function execute() {

        var myActions = actionPayloads
        for (var i = 0; i < myActions.count; i++) {
            var act = myActions.get(i);
            if(act.ttype === "groups") {
                var url = act.ttype + "/" + act.tid + "/action";
            }
            else {
                var url = act.ttype + "/" + act.tid + "/state";
            }
            debugPrint("Executing " + url + " with payload: " + act.payload)
            Hue.putPayloadToUrl(url, act.payload, successCallback, failureCallback)
        }
    }

    function successCallback(json, doneCallback) {
        debugPrint("Success callback with json: " + json);

        try {
            var myResult = JSON.parse(json);
        }
        catch(e) {
            debugPrint("Failed to parse json: " + json);
            doneCallback();
            return;
        }
        if(myResult[0]) {
            if(myResult[0].error) {
                if(myResult[0].error.type == 1) {
                    //TODO: Unauthorized
                }
                if(myResult[0].error.type == 3) {
                    //TODO: unavailable
                }
            }
        }
        reInit(false, true);
        doneCallback();
    }

    function failureCallback(request, doneCallback) {
        debugPrint("Failure callback with code: " + request.status + " and json: " + json);
        doneCallback();
    }

    function getIcon() {
        if(icon) {
            return icon;
        }
        else {
            return defaultIcon;
        }
    }
}
