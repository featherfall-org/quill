--[[
    https://github.com/ffrostfall/fluid/blob/d7ddeb064bb3ad1d9628b7f6998d6ddef76cca5b/src/instances/create.luau

    Copyright © 2025 ffrostfall

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

export type Instances = {
    AudioChannelSplitter: AudioChannelSplitter,
    AudioPitchShifter: AudioPitchShifter,
    AudioDeviceOutput: AudioDeviceOutput,
    AudioChannelMixer: AudioChannelMixer,
    AudioTextToSpeech: AudioTextToSpeech,
    AudioDeviceInput: AudioDeviceInput,
    AudioDistortion: AudioDistortion,
    AudioCompressor: AudioCompressor,
    AudioEqualizer: AudioEqualizer,
    AudioAnalyzer: AudioAnalyzer,
    AudioListener: AudioListener,
    AudioRecorder: AudioRecorder,
    AudioLimiter: AudioLimiter,
    AudioFlanger: AudioFlanger,
    AudioEmitter: AudioEmitter,
    AudioPlayer: AudioPlayer,
    AudioReverb: AudioReverb,
    AudioFilter: AudioFilter,
    ArcHandles: ArcHandles,
    AudioFader: AudioFader,
    AudioEcho: AudioEcho,
    AdGui: AdGui,
    BoxHandleAdornment: BoxHandleAdornment,
    BillboardGui: BillboardGui,
    BlurEffect: BlurEffect,
    CylinderHandleAdornment: CylinderHandleAdornment,
    ConeHandleAdornment: ConeHandleAdornment,
    CanvasGroup: CanvasGroup,
    Camera: Camera,
    DialogChoice: DialogChoice,
    DragDetector: DragDetector,
    Dialog: Dialog,
    Folder: Folder,
    Frame: Frame,
    Highlight: Highlight,
    Handles: Handles,
    ImageHandLeAdornment: ImageHandleAdornment,
    ImageButton: ImageButton,
    ImageLabel: ImageLabel,
    LineHandleAdornment: LineHandleAdornment,
    ProximityPrompt: ProximityPrompt,
    BasePart: BasePart,
    Part: Part,
    Model: Model,
    PVInstance: PVInstance,
    Attachment: Attachment,
    Humanoid: Humanoid,
    SphereHandleAdornment: SphereHandleAdornment,
    SelectionSphere: SelectionSphere,
    ScrollingFrame: ScrollingFrame,
    SelectionBox: SelectionBox,
    StyleDerive: StyleDerive,
    SurfaceGui: SurfaceGui,
    StyleSheet: StyleSheet,
    SoundGroup: SoundGroup,
    StyleLink: StyleLink,
    ScreenGui: ScreenGui,
    StyleBase: StyleBase,
    StyleRule: StyleRule,
    Sound: Sound,
    TextButton: TextButton,
    TextLabel: TextLabel,
    TextBox: TextBox,
    UIAspectRatioConstraint: UIAspectRatioConstraint,
    UITextSizeConstraint: UITextSizeConstraint,
    UISizeConstraint: UISizeConstraint,
    UIDragDetector: UIDragDetector,
    UITableLayout: UITableLayout,
    UIPageLayout: UIPageLayout,
    UIGridLayout: UIGridLayout,
    UIListLayout: UIListLayout,
    UIGradient: UIGradient,
    UIFlexItem: UIFlexItem,
    UIPadding: UIPadding,
    UIStroke: UIStroke,
    UICorner: UICorner,
    UIScale: UIScale,
    ViewportFrame: ViewportFrame,
    VideoFrame: VideoFrame,
    WireframeHandleAdornment: WireframeHandleAdornment,
    WorldModel: WorldModel,
    Wire: Wire,
}

type instance = Instance

export type function GetInstance(class_name: type, instances: type): type
    if not class_name:is("singleton") then
        return instance
    end

    return instances:readproperty(class_name) or instance
end

return {}
