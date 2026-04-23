import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property var defaultCategories: [
        "dark",
        "fun",
        "skyline",
        "happy",
        "nature",
        "city"
    ]

    property alias cfg_changeWallpaper: wallpaperCheck.checked
    property alias cfg_intervalMinutes: intervalSpin.value
    property alias cfg_category: categoryCombo.editText
    property alias cfg_customCategories: customCategoriesField.text
    property alias cfg_resolutionWidth: widthSpin.value
    property alias cfg_resolutionHeight: heightSpin.value
    property alias cfg_unsplashAccessKey: keyField.text

    function parseCustomCategories(text) {
        return text
            .split(",")
            .map(function(category) {
                return category.trim();
            })
            .filter(function(category, index, categories) {
                return category.length > 0 && categories.indexOf(category) === index;
            });
    }

    function rebuildCategoryModel() {
        var categories = defaultCategories.slice();
        var customCategories = parseCustomCategories(customCategoriesField.text);
        var currentCategory = categoryCombo.editText ? categoryCombo.editText.trim() : "";

        for (var i = 0; i < customCategories.length; i++) {
            if (categories.indexOf(customCategories[i]) === -1) {
                categories.push(customCategories[i]);
            }
        }

        if (currentCategory.length > 0 && categories.indexOf(currentCategory) === -1) {
            categories.unshift(currentCategory);
        }

        categoryCombo.model = categories;
    }

    Kirigami.FormLayout {
        CheckBox {
            id: wallpaperCheck
            Kirigami.FormData.label: "Desktop background"
            text: "Change wallpaper after each refresh"
        }

        SpinBox {
            id: intervalSpin
            Kirigami.FormData.label: "Refresh interval (minutes)"
            from: 1
            to: 1440
        }

        ComboBox {
            id: categoryCombo
            Kirigami.FormData.label: "Category / query"
            editable: true
            model: defaultCategories
            onEditTextChanged: rebuildCategoryModel()
        }

        TextField {
            id: customCategoriesField
            Kirigami.FormData.label: "Saved custom categories"
            placeholderText: "Comma-separated, for example: mountains, night city, minimal"
            onTextChanged: rebuildCategoryModel()
        }

        SpinBox {
            id: widthSpin
            Kirigami.FormData.label: "Resolution width"
            from: 640
            to: 7680
        }

        SpinBox {
            id: heightSpin
            Kirigami.FormData.label: "Resolution height"
            from: 480
            to: 4320
        }

        TextField {
            id: keyField
            Kirigami.FormData.label: "Unsplash Access Key"
            placeholderText: "Paste your Unsplash API access key"
            echoMode: TextInput.Password
        }
    }

    Component.onCompleted: rebuildCategoryModel()
}
