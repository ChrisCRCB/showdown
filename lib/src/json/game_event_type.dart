/// The types of events which can occur in a game.
enum GameEventType {
  /// The player scored a goal.
  goal,

  /// Short server foul.
  shortServe,

  /// Long serve foul.
  longServe,

  /// Hand foul.
  handFoul,

  /// Body touch.
  bodyTouch,

  /// The ball was out.
  out,

  /// Screen infraction.
  screenInfraction,

  /// A service fault.
  serviceFault,

  /// Illegal defence.
  illegalDefence,

  /// Talking during play.
  talking,
}
