let autofillEnabled = chrome.privacy.services.autofillAddressEnabled
autofillEnabled.get({}, result => result.value && autofillEnabled.set({value: false}))

let savingEnabled = chrome.privacy.services.passwordSavingEnabled
savingEnabled.get({}, result => result.value && savingEnabled.set({value: false}))

// Unnecessary since controlled via the command flag --disable-features=Translate
// let translationEnabled = chrome.privacy.services.translationServiceEnabled
// translationEnabled.get({}, result => result.value && translationEnabled.set({value: false}))
