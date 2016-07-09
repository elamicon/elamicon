//import Maybe, Native.List //

var _sbalmer$elamicon$Native_RegexMaybe = function() {

function regex(raw)
{
    try {
        return _elm_lang$core$Maybe$Just(new RegExp(raw, 'g'));
    } catch(e) {
        return _elm_lang$core$Maybe$Nothing
    }
}

return {
	regex: regex,
};

}();
