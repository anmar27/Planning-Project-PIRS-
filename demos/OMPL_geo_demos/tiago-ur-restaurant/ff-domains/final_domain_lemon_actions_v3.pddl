<<<<<<< HEAD
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
=======
(define (domain lemon-glass-manipulation)
    (:requirements :strips :typing)
    
    (:types
        location
        object
        robot
    )
    
    (:predicates
        ;; Location-related predicates
        (at ?obj - object ?loc - location)
        (at-robot ?r - robot ?loc - location)
        
        ;; Object state predicates
        (holding ?r - robot ?obj - object)
        (holding-multiple ?r - robot ?obj1 - object ?obj2 - object)
        
        ;; Special state predicates
        (on-glass ?obj - object)
        (empty-hand ?r - robot)
    )
    
    ;; Action to move robot between locations
    (:action move
        :parameters (?r - robot ?from - location ?to - location)
        :precondition (and 
            (at-robot ?r ?from)
            (not (= ?from ?to))
        )
        :effect (and 
            (not (at-robot ?r ?from))
            (at-robot ?r ?to)
        )
    )
    
    ;; Action to pick a single object
    (:action pick
        :parameters (?r - robot ?obj - object ?loc - location)
        :precondition (and 
            (at-robot ?r ?loc)
            (at ?obj ?loc)
            (empty-hand ?r)
        )
        :effect (and 
            (not (at ?obj ?loc))
            (holding ?r ?obj)
            (not (empty-hand ?r))
        )
    )
    
(:action putonglass
    :parameters (?r - robot ?obj - object ?glass - object ?loc - location)
    :precondition (and 
        (holding ?r ?obj)
        (at-robot ?r ?loc)
        (at ?glass ?loc) ;; Glass must be at the same location
        (not (on-glass ?obj))
    )
    :effect (and 
        (on-glass ?obj)
        (not (holding ?r ?obj))
        (empty-hand ?r)
    )
)

    
(:action pickmultiple
    :parameters (?r - robot ?obj1 - object ?obj2 - object ?loc - location)
    :precondition (and 
        (at-robot ?r ?loc)
        (on-glass ?obj1) ;; Lemon (obj1) must be on the glass (obj2)
        (at ?obj2 ?loc)  ;; Glass (obj2) must be at the same location
        (empty-hand ?r)
    )
    :effect (and 
        (not (at ?obj1 ?loc))
        (not (at ?obj2 ?loc))
        (holding-multiple ?r ?obj1 ?obj2)
        (not (empty-hand ?r))
    )
)


    
    ;; Action to place both objects at a location
    (:action placefullglass
        :parameters (?r - robot ?obj1 - object ?obj2 - object ?loc - location)
        :precondition (and 
            (holding-multiple ?r ?obj1 ?obj2)
            (at-robot ?r ?loc)
            (on-glass ?obj1)
        )
        :effect (and 
            (at ?obj1 ?loc)
            (at ?obj2 ?loc)
            (empty-hand ?r)
            (not (holding-multiple ?r ?obj1 ?obj2))
        )
    )
)
>>>>>>> origin/amf-branch
