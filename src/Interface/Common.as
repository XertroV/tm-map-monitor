bool ControlButton(const string &in label, CoroutineFunc@ onClick, vec2 size = vec2()) {
    bool ret = UI::Button(label, size);
    if (ret) onClick();
    UI::SameLine();
    return ret;
}
