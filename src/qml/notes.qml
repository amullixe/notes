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
import QtQuick.Dialogs 1.1

ApplicationWindow {
    width: 950
    height: 500
    visible: true
    title: 'Notes'
    id: app_window

    GridLayout {
        id: grid
        anchors.fill: parent
        rows: 12
        columns: 12
        property double colMulti: grid.width / grid.columns
        property double rowMulti: grid.height / grid.rows

        // get the right size of the element based on the size of the window
        function get_pref_width(item) {
            return colMulti * item.Layout.columnSpan
        }

        function get_pref_height(item) {
            return rowMulti * item.Layout.rowSpan
        }

        // show message dialog depending on the success of the operation
        function show_result_message_dialog(is_oper_success) {
            if (is_oper_success) {
                var success_update_note = notes_app.get_success_message_query_property
                custom_message_dialog.setSource("Custom_message_dialog.qml", {"title_for_custom_message_dialog": success_update_note['title'], "text_for_custom_message_dialog": success_update_note['text'], "message_dialog_visible": true})
                } else {
                    var error_update_note = notes_app.get_error_message_query_property
                     custom_message_dialog.setSource("Custom_message_dialog.qml", {"title_for_custom_message_dialog": error_update_note['title'], "text_for_custom_message_dialog": error_update_note['text'], "message_dialog_visible": true})
                }
        }

        ListModel {
            id: imagesModel
            objectName: "image_model_object_name"

            // appending [note, title] to the list model
            function append_to_list_model(title, note, saved) {
                imagesModel.append({"text_title": title, "textarea_text_delegate": note, "saved": saved})
            }

            /* 
            delete current index from the list model if there's
            two and more data in the list. Otherwise - append
            new note and delete the current one.
             */ 
            function delete_from_list_model_by_index() {
                if(listview_id.currentIndex > 0) {
                    listview_id.currentIndex = listview_id.currentIndex - 1
                    imagesModel.remove(listview_id.currentIndex + 1, 1)
                } else if (listview_id.currentIndex == 0 && imagesModel.count > 1) {
                    listview_id.currentIndex = listview_id.currentIndex + 1
                    imagesModel.remove(listview_id.currentIndex - 1, 1)
                } else {
                    imagesModel.append_to_list_model("", "", false)
                    listview_id.currentIndex = listview_id.count - 1
                    imagesModel.remove(listview_id.currentIndex - 1, 1)
                }
            }
        }

        ListView {
            id: listview_id
            Layout.rowSpan: 12
            Layout.columnSpan: 2
            Layout.row: 1
            Layout.column: 1
            Layout.preferredWidth: grid.get_pref_width(this)
            Layout.preferredHeight: grid.get_pref_height(this)
            
            model: imagesModel
            delegate: Note_images { }
            spacing: 2

            onCurrentItemChanged: function show_right_data_when_changing_notes(params) {
                title_txt_field.text = imagesModel.get(listview_id.currentIndex).text_title
                textarea.text = imagesModel.get(listview_id.currentIndex).textarea_text_delegate
            } 
        }

        TextField {
            id: title_txt_field
            objectName: "title_txt_object_name"
            Layout.rowSpan: 1
            Layout.columnSpan: 12
            Layout.row: 1
            Layout.column: 3
            Layout.preferredWidth: grid.get_pref_width(this)
            Layout.preferredHeight: grid.get_pref_height(this)

            placeholderText: "Title*"
            validator: RegExpValidator { regExp: /([\W]*((\w+[ ]*\w)+|(\w)+)[\W]*)+/ }

            // show title on the note in current ListView
            onEditingFinished: function set_curr_value_to_list_model(params) {
                imagesModel.set(listview_id.currentIndex, {"text_title": title_txt_field.text})
            }
        }

        ScrollView {
            id: view
            Layout.rowSpan: 9
            Layout.columnSpan: 9
            Layout.row: 2
            Layout.column: 3
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: grid.get_pref_width(this)
            Layout.preferredHeight: grid.get_pref_height(this)

            TextArea {
                id: textarea
                selectByMouse: true
                objectName: "textarea_object_name"
                placeholderText: "Enter text..."
                implicitWidth: 1

                onEditingFinished: function set_curr_value_to_list_model(params) {
                    imagesModel.set(listview_id.currentIndex, {"textarea_text_delegate": textarea.text})
                }
            }
        }

        Pane {
            Layout.rowSpan: 2
            Layout.columnSpan: 9
            Layout.row: 11
            Layout.column: 3
            Layout.preferredWidth: grid.get_pref_width(this)
            Layout.preferredHeight: grid.get_pref_height(this)

            RowLayout {
                id: buttons
                spacing: 12

                Button {
                    id: clear_btn
                    text: "Clear"
                    objectName: "clear_btn_object_name"

                    onClicked: function clear_current_fields(params) {
                        title_txt_field.text = ""
                        textarea.text = ""
                        imagesModel.set(listview_id.currentIndex, {"text_title": ""})
                        imagesModel.set(listview_id.currentIndex, {"textarea_text_delegate": ""})
                    }
                }

                Button {
                    id: save_btn
                    text: "Save"
                    objectName: "save_btn_object"
                    enabled: title_txt_field.acceptableInput

                    /*
                    Save or update the note depending 
                    on if the title already exists in the db
                    */
                    onClicked: function save_note(params) {
                        imagesModel.set(listview_id.currentIndex, {"saved": true})

                        var is_title_already_exists_in_db = notes_app.check_if_title_exists_in_db(title_txt_field.text)

                        if(!is_title_already_exists_in_db) {
                            var data_to_save = [{'text_title': title_txt_field.text, 'textarea_text_delegate': textarea.text}]
                            var save_success = notes_app.save_data_in_db( JSON.stringify(data_to_save) )
                            grid.show_result_message_dialog(save_success)
                        } else {
                            message_dialog_save_issue.visible = true
                        }
                    }
                }

                Button {
                    id: add_new_note_btn
                    text: "Add new note"
                    
                    onClicked: function add_note(params) {
                        imagesModel.append_to_list_model("","", false)
                        listview_id.currentIndex = listview_id.count - 1
                    } 
                }

                Button {
                    id: delete_current_note_btn
                    text: "Delete current note"
                    
                    onClicked: function delete_note(params) {
                        var curr_text = title_txt_field.text;

                        imagesModel.delete_from_list_model_by_index()
                        var is_title_exists_in_db = notes_app.check_if_title_exists_in_db(curr_text)

                        if (is_title_exists_in_db) {
                            var delete_success = notes_app.delete_data_from_db(curr_text)
                            if (delete_success != true) {
                                var failed_delete_from_db = notes_app.get_error_message_query_property
                                custom_message_dialog.setSource("Custom_message_dialog.qml", {"title_for_custom_message_dialog": failed_delete_from_db['title'], "text_for_custom_message_dialog": failed_delete_from_db['text'], "message_dialog_visible": true})
                                return
                            }
                        }
                        var success_delete_from_db = notes_app.get_success_message_query_property
                        custom_message_dialog.setSource("Custom_message_dialog.qml", {"title_for_custom_message_dialog": success_delete_from_db['title'], "text_for_custom_message_dialog": success_delete_from_db['text'], "message_dialog_visible": true})
                    } 
                }

                Button {
                    id: save_all_notes_btn
                    text: "Save all notes"
                    
                    onClicked: function save_all_notes(params) {
                        var data_to_save = []
                        var saved_data_indexes = []

                        // find which notes need to be saved
                        for(var i = 0; i < imagesModel.count; i++) {
                            print(imagesModel.get(i).saved)
                            if( imagesModel.get(i).saved == false ) {
                                data_to_save.push(imagesModel.get(i))
                                saved_data_indexes.push(i)
                            }
                        }
                        // if array isn't empty, then try to save the notes
                        if(data_to_save.length != 0) {
                            var insert_success = notes_app.save_data_in_db(JSON.stringify(data_to_save))
                            // change saved data in the list model
                            for(var i = 0; i < saved_data_indexes.length; i++) {
                                imagesModel.set(i, {'saved': true})
                            }
                            // show successfull information about saving the data
                            grid.show_result_message_dialog(insert_success)
                        } else {
                            custom_message_dialog.setSource("Custom_message_dialog.qml", {"title_for_custom_message_dialog": "No data to save", "text_for_custom_message_dialog": "There's no new data to save.", "message_dialog_visible": true})
                        }
                        
                    } 
                }
                
                Button {
                    id: delete_all_notes_btn
                    text: "Delete all notes"
                    objectName: "delete_all_notes_btn_object_name"

                    onClicked: function delete_all_notes(params) { 
                        message_dialog_delete_all_notes.visible = true
                    }
                }
            }

            MessageDialog {
                id: message_dialog_delete_all_notes
                icon: StandardIcon.Question
                objectName: "message_dialog_delete_all_notesobject_name"
                title: "Delete all notes"
                text: "Are you sure about deleting all notes?"
                standardButtons: StandardButton.Yes | StandardButton.No

                onYes: function delete_all_notes(params) {
                    var update_success = notes_app.delete_data_from_db()
                    grid.show_result_message_dialog(update_success)
                    imagesModel.clear()
                    imagesModel.append_to_list_model('', '', false)
                }
            }

            MessageDialog {
                id: message_dialog_save_issue
                icon: StandardIcon.Question
                objectName: "message_dialog_save_issue_object_name"
                title: "Save issues"
                text: "Cannot save the note because of this title already exists. Do you want to update the note?"
                standardButtons: StandardButton.Yes | StandardButton.No

                onYes: function update_the_note(params) {
                    var update_success = notes_app.update_the_note(title_txt_field.text, textarea.text)
                    grid.show_result_message_dialog(update_success)
                }
            }

            MessageDialog {
                id: message_dialog_save_success
                icon: StandardIcon.Information
                objectName: "message_dialog_save_success_object_name"
                title: "Save is complete"
                text: "The note saved successful."
                standardButtons: StandardButton.Yes
                
                onAccepted: {
                    Qt.quit()
                }
            }

            MessageDialog {
                id: dialog_create_db_error
                icon: StandardIcon.Information
                objectName: "dialog_create_db_error_obj"
                title: ""
                text: ""
                standardButtons: StandardButton.Yes
            }

        }
    }
    Loader {
        id: custom_message_dialog
        objectName: "custom_message_dialog_object_name"
        source: "Custom_message_dialog.qml"
    }
}