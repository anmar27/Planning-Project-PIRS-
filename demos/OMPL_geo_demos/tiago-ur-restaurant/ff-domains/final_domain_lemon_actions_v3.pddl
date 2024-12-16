(define (domain lemon-manipulation)
  (:requirements :strips :typing)

  (:types
    location    ; Different locations 
    robot       ; Robots involved in the task
    object      ; Generic objects that can be moved
  )

  (:predicates
    ; Location-based predicates
    (at ?obj - object ?loc - location)
    (robot_at ?r - robot ?loc - location)

    ; Object manipulation predicates
    (holding ?r - robot ?obj - object)
    (empty_hand ?r - robot)


    ; Location types
    (is_lowercounter ?loc - location)
    (is_glass ?loc - location)

    ; Robot capabilities
    (can_reach ?r - robot ?loc - location)

    ; Object characteristics
    (is_glass_object ?obj - object)
  )

  (:action pick
    :parameters (?r - robot ?obj - object ?loc - location)
    :precondition (and
      (robot_at ?r ?loc)
      (at ?obj ?loc)
      (empty_hand ?r)
      (can_reach ?r ?loc)
    )
    :effect (and
      (not (at ?obj ?loc))
      (holding ?r ?obj)
      (not (empty_hand ?r))
    )
  )


  (:action move
    :parameters (?r - robot ?from ?to - location)
    :precondition (and
      (robot_at ?r ?from)
      (can_reach ?r ?to)
    )
    :effect (and
      (robot_at ?r ?to)
      (not (robot_at ?r ?from))
    )
  )
)
