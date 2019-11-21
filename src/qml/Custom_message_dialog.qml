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

    The full license agreement can be found in the following link:
    https://github.com/evilixy/notes/blob/master/LICENSE

    You can contact me via email: mivilixe@outlook.com
*/

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.11
import QtQuick.Dialogs 1.1

Item {
    id: item_for_messsage_dialog
    property string title_for_custom_message_dialog: ""
    property string text_for_custom_message_dialog: ""
    property bool message_dialog_visible: false
    width: 100

    MessageDialog {
        id: custom_message_dialog
        icon: StandardIcon.Information
        title: item_for_messsage_dialog.title_for_custom_message_dialog
        text: item_for_messsage_dialog.text_for_custom_message_dialog
        visible: item_for_messsage_dialog.message_dialog_visible
        standardButtons: StandardButton.Yes
                
        onAccepted: {
            Qt.quit()
        }
    }

}