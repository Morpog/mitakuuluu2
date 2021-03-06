TEMPLATE = aux

TS_FILE = $$PWD/mitakuuluu2.ts

ts.commands += lupdate $$PWD/.. -ts $$TS_FILE
ts.CONFIG += no_check_exist no_link
ts.output = $$TS_FILE
ts.input = ..

QMAKE_EXTRA_TARGETS += ts
PRE_TARGETDEPS += ts

TRANSLATIONS += \
    ru_RU.ts \
    $${NULL}

build_translations.target = build_translations
build_translations.commands += lrelease \"$${_PRO_FILE_}\"

QMAKE_EXTRA_TARGETS += build_translations
POST_TARGETDEPS += build_translations

qm.files = $$replace(TRANSLATIONS, .ts, .qm)
qm.path = /usr/share/harbour-mitakuuluu2/locales
qm.CONFIG += no_check_exist

INSTALLS += qm

OTHER_FILES += $$TRANSLATIONS

