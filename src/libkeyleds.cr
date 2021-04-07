@[Link("keyleds")]
lib LibKeyleds
  # Zero-length arrays are VLAs, https://github.com/crystal-lang/crystal/issues/10598

  $keyleds_block_id_names : IndexedString[0]
  $keyleds_device_types   : IndexedString[0]
  $keyleds_feature_names  : IndexedString[0]
  $keyleds_keycode_names  : IndexedString[0]
  $keyleds_protocol_types : IndexedString[0]

  alias GkeysCb = (Keyleds, UInt8, GkeysType, UInt16, Void* -> Void)

  enum BlockId
    Keys       =  1
    Multimedia =  2
    Gkeys      =  4
    Logo       = 16
    Modes      = 64
    Invalid    = -1
  end

  enum DeviceHandler
    Device     =   1
    Gaming     =   2
    Preference =   4
    Feature    = 128
  end

  enum DeviceType
    Keyboard  = 0
    Remote    = 1
    Numpad    = 2
    Mouse     = 3
    Touchpad  = 4
    Trackball = 5
    Presenter = 6
    Receiver  = 7
  end

  enum Error
    None            =  0
    Errno           =  1
    Device          =  2
    IoLength        =  3
    Hidreport       =  4
    Hidnopp         =  5
    Hidversion      =  6
    FeatureNotFound =  7
    Timedout        =  8
    Response        =  9
    Inval           = 10
  end

  enum GkeysType
    Gkey  = 0
    Mkey  = 1
    Mrkey = 2
  end

  enum KeyboardLayout
    Fra     =  5
    Invalid = -1
  end

  APP_ID_MIN = 0x0_u8
  APP_ID_MAX = 0xf_u8

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
  fun get_device_type = keyleds_get_device_type(device : Keyleds, target_id : UInt8, out : DeviceType*) : Bool
  fun get_device_version = keyleds_get_device_version(device : Keyleds, target_id : UInt8, out : DeviceVersion**) : Bool
  fun get_errno = keyleds_get_errno : Error
  fun get_error_str = keyleds_get_error_str : LibC::Char*
  fun get_feature_count = keyleds_get_feature_count(dev : Keyleds, target_id : UInt8) : LibC::UInt
  fun get_feature_id = keyleds_get_feature_id(dev : Keyleds, target_id : UInt8, feature_idx : UInt8) : UInt16
  fun get_feature_index = keyleds_get_feature_index(dev : Keyleds, target_id : UInt8, feature_id : UInt16) : UInt8
  fun get_leds = keyleds_get_leds(device : Keyleds, target_id : UInt8, block_id : BlockId, keys : KeyColor*, offset : UInt16, keys_nb : LibC::UInt) : Bool
  fun get_protocol = keyleds_get_protocol(device : Keyleds, target_id : UInt8, version : LibC::UInt*, handler : DeviceHandler*) : Bool
  fun get_reportrate = keyleds_get_reportrate(device : Keyleds, target_id : UInt8, rate : LibC::UInt*) : Bool
  fun get_reportrates = keyleds_get_reportrates(device : Keyleds, target_id : UInt8, out : LibC::UInt**) : Bool
  fun gkeys_count = keyleds_gkeys_count(device : Keyleds, target_id : UInt8, nb : LibC::UInt*) : Bool
  fun gkeys_enable = keyleds_gkeys_enable(device : Keyleds, target_id : UInt8, enabled : Bool) : Bool
  fun gkeys_set_cb = keyleds_gkeys_set_cb(device : Keyleds, target_id : UInt8, x2 : GkeysCb, userdata : Void*)
  fun keyboard_layout = keyleds_keyboard_layout(device : Keyleds, target_id : UInt8) : KeyboardLayout
  fun lookup_string = keyleds_lookup_string(x0 : IndexedString*, id : LibC::UInt) : LibC::Char*
  fun mkeys_set = keyleds_mkeys_set(device : Keyleds, target_id : UInt8, mask : UInt8) : Bool
  fun mrkeys_set = keyleds_mrkeys_set(device : Keyleds, target_id : UInt8, mask : UInt8) : Bool
  fun open = keyleds_open(path : LibC::Char*, app_id : UInt8) : Keyleds
  fun ping = keyleds_ping(device : Keyleds, target_id : UInt8) : Bool
  fun set_led_block = keyleds_set_led_block(device : Keyleds, target_id : UInt8, block_id : BlockId, red : UInt8, green : UInt8, blue : UInt8) : Bool
  fun set_leds = keyleds_set_leds(device : Keyleds, target_id : UInt8, block_id : BlockId, keys : KeyColor*, keys_nb : LibC::UInt) : Bool
  fun set_reportrate = keyleds_set_reportrate(device : Keyleds, target_id : UInt8, rate : LibC::UInt) : Bool
  fun set_timeout = keyleds_set_timeout(device : Keyleds, us : LibC::UInt)
  fun string_id = keyleds_string_id(x0 : IndexedString*, str : LibC::Char*) : LibC::UInt
  fun translate_keycode = keyleds_translate_keycode(keycode : LibC::UInt, block : BlockId*, scancode : UInt8*) : Bool
  fun translate_scancode = keyleds_translate_scancode(block : BlockId, scancode : UInt8) : LibC::UInt

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
    blocks : Keyblock[0]
  end

  struct Keyblock
    block_id : BlockId
    nb_keys : UInt16
    red : UInt8
    green : UInt8
    blue : UInt8
  end

  type Keyleds = Void*
end
