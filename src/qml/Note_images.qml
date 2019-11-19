/*
    Simple desktop application to store, create and delete notes
    Copyright (C) 2019 Andrey Mikhalev

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    Email: mivilixe@outlook.com
*/

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.11

Component {
    id: delegate_item

    Rectangle {
        id: rect_for_listview
        width: listview_id.width
        height: 100
        radius: 10
        color: ListView.isCurrentItem ? "indigo" : "red"

        Text {
            id: note_title
            text: text_title
            color: "white"
        }

        Text {
            id: textarea_delegate
            text: textarea_text_delegate
            visible: false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: function associate_listview_with_delegate(params) {
                listview_id.currentIndex = index
            } 
        }

    }
}