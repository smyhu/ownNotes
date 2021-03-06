import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import net.khertan.python 1.0
import 'components'

/* TODO
* Tests
* Detect available qt quick components set
*/

PageStackWindow {
    id: appWindow

    initialPage: mainPage

    Item {
        id: aboutInfos
        property string version:'1.3.0'
        property string text:'A note taking application with sync for ownCloud or any WebDav.' +
                           '<br>Web Site : http://khertan.net/ownnotes' +
                           '<br><br>By Benoît HERVIER (Khertan)' +
                           '<br><b>Licensed under GPLv3</b>' +
                           '<br><br><b>Changelog : </b><br>' +
                           '<br>1.0.0 : <br>' +
                           '  * Initial Fork from KhtNotes<br>' +
                           '  * Use PyOtherSide instead of PySide<br>' +
                           '<br>1.0.1 : <br>' +
                           '  * Add auto sync at launch<br>' +
                           '  * Push modification of a note to server once saved<br>' +
                           '<br>1.0.2 : <br>' +
                           '  * Fix rehighlighting that can lose cursor position<br>' +
                           '<br>1.1.0 : <br>' +
                           '  * First Desktop UX release<br>' +
                           '  * Fix an other rehighlight bug<br>' +
                           '<br>1.1.2 : <br>' +
                           '  * Fix incorrect font size of the editor on SailfishOS.<br>' +
                           '<br>1.2.0 : <br>' +
                           '  * Fix rehighlighting bug<br>' +
                           '  * Russian and French translation of Sailfish UI<br>' +
                           '  * Fix sync encoding error<br>' +
                           '<br>1.2.1 : <br>' +
                           '  * Fix sync encoding error<br>' +
                           '<br>1.2.2 : <br>' +
                           '  * Fix encoding error in notes list view<br>' +
                           '<br>1.2.3 : <br>' +
                           '  * Bump release version (as previous release didn\'t display right version)<br>' +
                           '<br>1.2.4 : <br>' +
                           '  * Add translation (Sailfish)<br>' +
                           '  * Fix about (Sailfish)<br>' +
                           '  * Add a workarround for link color in About (Sailfish)<br>' +
                           '<br>1.3.0 : <br>' +
                           '  * Rewrite synchronisation (works now with ownCloud 4, 5, 6)<br>' +
                           '  * Add ssl certificate verification<br>' +
                           '  * Add preference to launch sync at startup<br>' +
                           '<br><br><b>Thanks to : </b>' +
                           '<br>Radek Novacek' +
                           '<br>caco3 on talk.maemo.org' +
                           '<br>Thomas Perl for PyOtherSide' +
                           '<br>Antoine Vacher for debugging help and tests' +
                           '<br><br><b>Privacy Policy : </b>' +
                           '<br>ownNotes can sync your notes with a webdav storage or ownCloud instance. For this ownNotes need to know the Url, Login and Password to connect to. But this is optionnal, and you can use ownNotes without the sync feature.' +
                           '<br><br>' +
                           'Which datas are transmitted :' +
                           '<br>* Login and Password will only be transmitted to the url you put in the Web Host setting.' +
                           '<br>* When using the sync features all your notes can be transmitted to the server you put in the Web Host setting' +
                           '<br><br>' +
                           'Which datas are stored :' +
                           '<br>* All notes are stored as text files' +
                           '<br>* An index of all files, with last synchronization datetime' +
                           '<br>* Url & Path of the server, and login and password are stored in the settings file.'  +
                           '<br><br>' +
                           '<b>Markdown format :</b>' +
                           '<br>For a complete documentation on the markdown format,' +
                             ' see <a href="http://daringfireball.net/projects/markdown/syntax">Daringfireball Markdown Syntax</a>. Hilighting on ownNotes support only few tags' +
                           'of markdown syntax: title, bold, italics, links'
    }


    MainPage {
        id: mainPage
    }


    Python {
        id: sync
        property bool running: false

        function launch() {
            if (!running) {
                running = true;
                threadedCall('ownnotes.launchSync', []);
            }
        }

        onFinished: {
            running = false;
            pyNotes.listNotes(mainPage.searchFieldText);
        }

        onMessage: {
            //console.log('Sync:'+data)
        }

        onException: {
            console.log(type + ' : ' + data)
            onError(type + ' : ' + data);
            running = false;
        }

        Component.onCompleted: {
            addImportPath('/opt/ownNotes/python');
            importModule('ownnotes');
        }

    }


    Python {
        id: pyNotes
        signal requireRefresh

        function loadNote(path) {
            var message = call('ownnotes.loadNote', [path,]);
            return message;
        }

        function listNotes(text) {
            threadedCall('ownnotes.listNotes', [text,]);
        }

        function getCategories() {
            var categories = call('ownnotes.getCategories', []);
            return categories;
        }

        function setCategory(path, category) {
            call('ownnotes.setCategory', [path, category]);
            requireRefresh();
        }

        function remove(path) {
            call('ownnotes.rm', [path, ]);
            requireRefresh();
        }

        function duplicate(path) {
            call('ownnotes.duplicate', [path, ]);
            requireRefresh();
        }

        function get(section, option) {
            return call('ownnotes.getSetting', [section, option])
        }

        function set(section, option, value) {
            call('ownnotes.setSetting', [section, option, value])
        }

        function createNote() {
            var path = call('ownnotes.createNote', []);
            return path;
        }

        function publishToScriptogram(text) {
            call('ownnotes.publishToScriptogram', [text]);
        }

        function publishAsPostToKhtCMS(text) {
            call('ownnotes.publishAsPostToKhtCMS', [text]);
        }

        function publishAsPageToKhtCMS(text) {
            call('ownnotes.publishAsPageToKhtCMS', [text]);
        }
        onException: {
            console.log(type + ' : ' + data);
            onError(type + ' : ' + message);
        }

        Component.onCompleted: {
            //addImportPath('python');
            addImportPath('/opt/ownNotes/python');
            importModule('ownnotes');
        }
    }


    function pushAbout() {
        pageStack.push(Qt.createComponent(Qt.resolvedUrl("components/AboutPage.qml")),
                       {
                           title : 'ownNotes ' + aboutInfos.version,
                           iconSource: Qt.resolvedUrl('../../icons/ownnotes.png'),
                           slogan : 'Notes in your own cloud !',
                           text : aboutInfos.text
                       }
                       );
    }

    function onError(errMsg) {
        errorEditBanner.text = errMsg;
        errorEditBanner.show();
    }

    InfoBanner{
        id:errorEditBanner
        text: ''
        topMargin: 40
        timerShowTime: 15000
        timerEnabled:true
        z:4
    }


    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: qsTr("About"); onClicked: pushAbout()}
            MenuItem { text: qsTr("Preferences"); onClicked: pageStack.push(Qt.createComponent(Qt.resolvedUrl("SettingsPage.qml"))); }
            MenuItem { text: qsTr("Report a bug");onClicked: {
                    Qt.openUrlExternally('https://github.com/khertan/ownNotes/issues/new');
                }
            }
        }
    }

}
