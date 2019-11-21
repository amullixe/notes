"""
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
"""

from PyQt5.QtWidgets import QApplication, QLabel, QMainWindow
from PyQt5.QtGui import QGuiApplication, QImage, QIcon
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QDataStream, QUrl, QDir, QObject, QMetaObject, QVariant, Q_ARG, QIODevice, QByteArray, QBuffer, pyqtProperty, pyqtSlot, QStringListModel
from PyQt5.QtQuick import QQuickView
from PyQt5.QtSql import QSqlDatabase, QSqlQuery
from strings import strings

import sys
import json
import resource_rc
import qml_resource

class Notes_app(QObject):

    def __init__(self, context, parent=None):
        super(Notes_app, self).__init__(parent)
        self.win = parent
        self.ctx = context
        self.success_message_query_property = {'title': strings['operation_success_title'], 'text': strings['operation_success_text']}

    @pyqtProperty('QVariant')
    def get_error_message_query_property(self):
        return self.error_message_query_property

    @pyqtProperty('QVariantMap')
    def get_success_message_query_property(self):
        return self.success_message_query_property

    @pyqtSlot(str)
    def show_dict_from_qml(self, list_data):
        data = json.loads(list_data)
        for val in data:
            print(val)

    @pyqtSlot(str, str, result=bool)
    def update_the_note(self, note_title, note):
        update_note_query = QSqlQuery()
        update_note_query.prepare("UPDATE notes SET note=:note WHERE note_title=:note_title;")

        update_note_query.bindValue(":note_title", note_title)
        update_note_query.bindValue(":note", note)

        query_result = self.exec_query(update_note_query)
        return query_result

    def exec_query(self, query):
        if query.exec_():
            return True
        else:
            error_query_message = (
                                    "There's SQLITE error: '{}'; error type: '{}'; query: '{}'."
                                    .format(query.lastError().text(),
                                    query.lastError().type(),
                                    query.executedQuery())
                                    )
            self.error_message_query_property = {'title': "Operation failed", 'text': error_query_message}
            return False

    def set_con_to_db(self):
        notes_db = QSqlDatabase.addDatabase("QSQLITE")
        
        # check if the directory is exists
        if not QDir("database").exists():
            QDir().mkdir("database")
            notes_db.setDatabaseName("database\\notes_db.db")
            # check if db can be opened
            if not notes_db.open():
                return
            create_db_query = QSqlQuery()
            create_db_query.prepare(
                                    f"CREATE TABLE notes ("
                                    f"'note_id' INTEGER PRIMARY KEY,"
                                    f"'note_title' TEXT NOT NULL UNIQUE,"
                                    f"'note' TEXT NOT NULL);"
                                    )
            is_create_success = self.exec_query(create_db_query)     

            if not is_create_success:
                # create message dialog about the error
                dialog_create_db_error_obj = window.findChild(QObject, "dialog_create_db_error_obj")
                dialog_create_db_error_obj.setProperty("title", QVariant(self.error_message_query_property['title']))
                dialog_create_db_error_obj.setProperty("text", QVariant(self.error_message_query_property['text'])) 
                dialog_create_db_error_obj.setProperty("visible", QVariant("true"))
        else:
            notes_db.setDatabaseName("database\\notes_db.db")

            if not notes_db.open():
                print(notes_db.lastError().text())
                return

    @pyqtSlot(str, result=bool)
    def check_if_title_exists_in_db(self, title):
        title_in_db_query = QSqlQuery()
        title_in_db_query.prepare("SELECT COUNT(*) AS count_note FROM notes WHERE note_title='" + title + "';")
        query_result = self.exec_query(title_in_db_query)

        if not query_result:
            return query_result
        
        count_note = 0

        while(title_in_db_query.next()):
            count_note = title_in_db_query.value(0)

        if count_note:
            return True
        else:
            return False

    @pyqtSlot(result=bool)
    @pyqtSlot(str, result=bool)
    def delete_data_from_db(self, title=None):

        title_in_db_query = QSqlQuery()

        if title is not None:
            title_in_db_query.prepare("DELETE FROM notes WHERE note_title=:title;")
            title_in_db_query.bindValue(":title", title)
        else:
            title_in_db_query.prepare("DELETE FROM notes;")
        query_result = self.exec_query(title_in_db_query)

        return query_result

    @pyqtSlot(str, result=bool)
    def save_data_in_db(self, json_data):
        data = json.loads(json_data)

        list_of_vals_to_insert = []

        # fill up list with values for insertion
        for data_val in data:
            list_of_vals_to_insert.append(f"('{data_val['text_title']}', '{data_val['textarea_text_delegate']}')")
        
        str_of_vals_to_insert = ",".join(list_of_vals_to_insert)

        # prepare the query
        add_to_db_query = QSqlQuery()
        add_to_db_query.prepare(f"INSERT INTO notes(note_title, note) VALUES {str_of_vals_to_insert};")

        query_result = self.exec_query(add_to_db_query)
        return query_result

    def get_row_count(self, query):
        rows_num = 0

        if query.last():
            rows_num = query.at() + 1
            query.first()
            query.previous()
        return rows_num

    # cols = [], db_name = string
    def get_data_from_db(self):

        result_data = []

        get_data_from_db_query = QSqlQuery()
        get_data_from_db_query.prepare("SELECT note_title, note FROM notes;")
        get_data_from_db_query.exec_()

        row_count = self.get_row_count(get_data_from_db_query)

        # if there's no records return empty relust_data
        if row_count == 0:
            return result_data

        while(get_data_from_db_query.next()):
            current_line_dict = {}
            current_line_dict['note_title'] = get_data_from_db_query.value(0)
            current_line_dict['note'] = get_data_from_db_query.value(1)

            result_data.append(current_line_dict)

        return result_data

    # data type = [{},{}]
    def fill_list_model_with_data(self, model, data):
        for val in data:
            title = val['note_title']
            note = val['note']

            QMetaObject.invokeMethod(model, "append_to_list_model", Q_ARG(QVariant, title), Q_ARG(QVariant, note), Q_ARG(QVariant, True))

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    #app.setWindowIcon(QIcon('notes.png'))
    engine = QQmlApplicationEngine()
    ctx = engine.rootContext()
    engine.load(QUrl('qrc:/notes.qml'))
    
    if not engine.rootObjects():
        sys.exit(-1)

    window = engine.rootObjects()[0]

    notes_app = Notes_app(ctx, window)

    ctx.setContextProperty("notes_app", notes_app)
    notes_app.set_con_to_db()

    # get ListModel from QML
    image_model = window.findChild(QObject, "image_model_object_name")
    
    # get data for filling model on start
    data_to_append = notes_app.get_data_from_db()

    # if db had some data - show it. Otherwise show an empty note
    if data_to_append:
        notes_app.fill_list_model_with_data(image_model, data_to_append)
    else:
        notes_app.fill_list_model_with_data(image_model, [{'note_title': '', 'note': ''}])

    sys.exit(app.exec_())