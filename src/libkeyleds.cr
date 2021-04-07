@[Link("keyleds")]
lib LibKeyleds
  $keyleds_block_id_names : IndexedString*
  $keyleds_device_types : IndexedString*
  $keyleds_feature_names : IndexedString*
  $keyleds_keycode_names : IndexedString*
  $keyleds_protocol_types : IndexedString*

  alias GkeysCb = (Keyleds, UInt8, GkeysTypeT, UInt16, Void* -> Void)

  enum BlockIdT
    BlockKeys       =  1
    BlockMultimedia =  2
    BlockGkeys      =  4
    BlockLogo       = 16
    BlockModes      = 64
    BlockInvalid    = -1
  end

  enum DeviceHandlerT
    DeviceHandlerDevice     =   1
    DeviceHandlerGaming     =   2
    DeviceHandlerPreference =   4
    DeviceHandlerFeature    = 128
  end

  enum DeviceTypeT
    DeviceTypeKeyboard  = 0
    DeviceTypeRemote    = 1
    DeviceTypeNumpad    = 2
    DeviceTypeMouse     = 3
    DeviceTypeTouchpad  = 4
    DeviceTypeTrackball = 5
    DeviceTypePresenter = 6
    DeviceTypeReceiver  = 7
  end

  enum ErrorT
    NoError              =  0
    ErrorErrno           =  1
    ErrorDevice          =  2
    ErrorIoLength        =  3
    ErrorHidreport       =  4
    ErrorHidnopp         =  5
    ErrorHidversion      =  6
    ErrorFeatureNotFound =  7
    ErrorTimedout        =  8
    ErrorResponse        =  9
    ErrorInval           = 10
  end

  enum GkeysTypeT
    GkeysGkey  = 0
    GkeysMkey  = 1
    GkeysMrkey = 2
  end

  enum KeyboardLayoutT
    KeyboardLayoutFra     =  5
    KeyboardLayoutInvalid = -1
  end

  TARGET_DEFAULT = 0xff_u8

  fun close = keyleds_close(device : Keyleds)
  fun commit_leds = keyleds_commit_leds(device : Keyleds, target_id : UInt8) : Bool
  fun device_fd = keyleds_device_fd(device : Keyleds) : LibC::Int
  fun flush_fd = keyleds_flush_fd(device : Keyleds) : Bool
  fun free_block_info = keyleds_free_block_info(info : KeyblocksInfo*)
  fun free_device_name = keyleds_free_device_name(x0 : LibC::Char*)
  fun free_device_version = keyleds_free_device_version(x0 : DeviceVersion*)
  fun free_reportrates = keyleds_free_reportrates(x0 : LibC::UInt*)
  fun gamemode_clear = keyleds_gamemode_clear(device : Keyleds, target_id : UInt8, ids : UInt8*, ids_nb : LibC::UInt) : Bool
  fun gamemode_max = keyleds_gamemode_max(device : Keyleds, target_id : UInt8, nb : LibC::UInt*) : Bool
  fun gamemode_reset = keyleds_gamemode_reset(device : Keyleds, target_id : UInt8) : Bool
  fun gamemode_set = keyleds_gamemode_set(device : Keyleds, target_id : UInt8, ids : UInt8*, ids_nb : LibC::UInt) : Bool
  fun get_block_info = keyleds_get_block_info(device : Keyleds, target_id : UInt8, out : KeyblocksInfo**) : Bool
  fun get_device_name = keyleds_get_device_name(device : Keyleds, target_id : UInt8, out : LibC::Char**) : Bool
  fun get_device_type = keyleds_get_device_type(device : Keyleds, target_id : UInt8, out : DeviceTypeT*) : Bool
  fun get_device_version = keyleds_get_device_version(device : Keyleds, target_id : UInt8, out : DeviceVersion**) : Bool
  fun get_errno = keyleds_get_errno : ErrorT
  fun get_error_str = keyleds_get_error_str : LibC::Char*
  fun get_feature_count = keyleds_get_feature_count(dev : Keyleds, target_id : UInt8) : LibC::UInt
  fun get_feature_id = keyleds_get_feature_id(dev : Keyleds, target_id : UInt8, feature_idx : UInt8) : UInt16
  fun get_feature_index = keyleds_get_feature_index(dev : Keyleds, target_id : UInt8, feature_id : UInt16) : UInt8
  fun get_leds = keyleds_get_leds(device : Keyleds, target_id : UInt8, block_id : BlockIdT, keys : KeyColor*, offset : UInt16, keys_nb : LibC::UInt) : Bool
  fun get_protocol = keyleds_get_protocol(device : Keyleds, target_id : UInt8, version : LibC::UInt*, handler : DeviceHandlerT*) : Bool
  fun get_reportrate = keyleds_get_reportrate(device : Keyleds, target_id : UInt8, rate : LibC::UInt*) : Bool
  fun get_reportrates = keyleds_get_reportrates(device : Keyleds, target_id : UInt8, out : LibC::UInt**) : Bool
  fun gkeys_count = keyleds_gkeys_count(device : Keyleds, target_id : UInt8, nb : LibC::UInt*) : Bool
  fun gkeys_enable = keyleds_gkeys_enable(device : Keyleds, target_id : UInt8, enabled : Bool) : Bool
  fun gkeys_set_cb = keyleds_gkeys_set_cb(device : Keyleds, target_id : UInt8, x2 : GkeysCb, userdata : Void*)
  fun keyboard_layout = keyleds_keyboard_layout(device : Keyleds, target_id : UInt8) : KeyboardLayoutT
  fun lookup_string = keyleds_lookup_string(x0 : IndexedString*, id : LibC::UInt) : LibC::Char*
  fun mkeys_set = keyleds_mkeys_set(device : Keyleds, target_id : UInt8, mask : UInt8) : Bool
  fun mrkeys_set = keyleds_mrkeys_set(device : Keyleds, target_id : UInt8, mask : UInt8) : Bool
  fun open = keyleds_open(path : LibC::Char*, app_id : UInt8) : Keyleds
  fun ping = keyleds_ping(device : Keyleds, target_id : UInt8) : Bool
  fun set_led_block = keyleds_set_led_block(device : Keyleds, target_id : UInt8, block_id : BlockIdT, red : UInt8, green : UInt8, blue : UInt8) : Bool
  fun set_leds = keyleds_set_leds(device : Keyleds, target_id : UInt8, block_id : BlockIdT, keys : KeyColor*, keys_nb : LibC::UInt) : Bool
  fun set_reportrate = keyleds_set_reportrate(device : Keyleds, target_id : UInt8, rate : LibC::UInt) : Bool
  fun set_timeout = keyleds_set_timeout(device : Keyleds, us : LibC::UInt)
  fun string_id = keyleds_string_id(x0 : IndexedString*, str : LibC::Char*) : LibC::UInt
  fun translate_keycode = keyleds_translate_keycode(keycode : LibC::UInt, block : BlockIdT*, scancode : UInt8*) : Bool
  fun translate_scancode = keyleds_translate_scancode(block : BlockIdT, scancode : UInt8) : LibC::UInt

  struct DeviceVersion
    serial : UInt8[4]
    transport : UInt16
    model : UInt8[6]
    length : LibC::UInt
    protocols : DeviceVersionProtocols*
  end

  struct DeviceVersionProtocols
    type : UInt8
    prefix : LibC::Char[4]
    version_major : LibC::UInt
    version_minor : LibC::UInt
    build : LibC::UInt
    is_active : Bool
    product_id : UInt16
    misc : UInt8[5]
  end

  struct IndexedString
    id : LibC::UInt
    str : LibC::Char*
  end

  struct KeyColor
    id : UInt8
    red : UInt8
    green : UInt8
    blue : UInt8
  end

  struct KeyblocksInfo
    length : LibC::UInt
    blocks : Keyblock
  end

  struct Keyblock
    block_id : BlockIdT
    nb_keys : UInt16
    red : UInt8
    green : UInt8
    blue : UInt8
  end

  type Keyleds = Void*
end
