# a handler which can take actions when any event occurs on a tween
# typedef void TweenCallbackHandler(int type, BaseTween source);

# TweenCallbacks are used to trigger actions at some specific times.
# They are used in both Tweens and Timelines.
# The moment when the callback is triggered depends on its registered triggers:
#
# * [TweenCallback.begin]: right after the delay (if any)
# * [TweenCallback.start]: at each iteration beginning
# * [TweenCallback.end]: at each iteration ending, before the repeat delay
# * [TweenCallback.complete]: at last END event
# * [TweenCallback.backBegin]: at the beginning of the first backward iteration
# * [TweenCallback.backStart]: at each backward iteration beginning, after the repeat delay
# * [TweenCallback.backEnd]: at each backward iteration ending
# * [TweenCallback.backComplete]: at last BACK_END event
#
# forward :      begin                                   complete
# forward :      start    end      start    end      start    end
# |--------------[XXXXXXXXXX]------[XXXXXXXXXX]------[XXXXXXXXXX]
# backward:      bEnd  bStart      bEnd  bStart      bEnd  bStart
# backward:      bComplete                                 bBegin

const TWEEN_CALLBACK_BEGIN = UInt64(0x01)
const TWEEN_CALLBACK_START = UInt64(0x02)
const TWEEN_CALLBACK_END = UInt64(0x04)
const TWEEN_CALLBACK_COMPLETE = UInt64(0x08)

const TWEEN_CALLBACK_BACK_BEGIN = UInt64(0x10)
const TWEEN_CALLBACK_BACK_START = UInt64(0x20)
const TWEEN_CALLBACK_BACK_END = UInt64(0x40)
const TWEEN_CALLBACK_BACK_COMPLETE = UInt64(0x80)

const TWEEN_CALLBACK_ANY_FORWARD = UInt64(0x0F)
const TWEEN_CALLBACK_ANY_BACKWARD = UInt64(0xF0)
const TWEEN_CALLBACK_ANY = UInt64(0xFF)

  