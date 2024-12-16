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

    ; Relationship predicates
    (is_child_of ?child - object ?father - object)

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
      (not (is_glass_object ?obj))
    )
    :effect (and
      (not (at ?obj ?loc))
      (holding ?r ?obj)
      (not (empty_hand ?r))
    )
  )

  (:action pickmultiple
    :parameters (?r - robot ?father - object ?loc - location)
    :precondition (and
      (robot_at ?r ?loc)
      (at ?father ?loc)
      (empty_hand ?r)
      (can_reach ?r ?loc)
      (is_glass_object ?father)
      ; Add additional constraint to ensure at least one child exists
      (exists (?child - object)
        (and 
          (is_child_of ?child ?father)
          (at ?child ?loc)
        )
      )
    )
    :effect (and
      ; Pick the father object
      (not (at ?father ?loc))
      (holding ?r ?father)
      (not (empty_hand ?r))
      ; Remove the child objects from the location
      (forall (?child - object)
        (when 
          (and 
            (is_child_of ?child ?father)
            (at ?child ?loc)
          )
          (not (at ?child ?loc))
        )
      )
    )
  )

  (:action putonglass
    :parameters (?r - robot ?obj - object ?loc - location)
    :precondition (and
      (robot_at ?r ?loc)
      (holding ?r ?obj)
      (is_glass ?loc)
      (can_reach ?r ?loc)
    )
    :effect (and
      (at ?obj ?loc)
      (not (holding ?r ?obj))
      (empty_hand ?r)
      ; Establish the is_child_of relationship
      (forall (?glass - object)
        (when (at ?glass ?loc)
          (is_child_of ?obj ?glass)
        )
      )
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
