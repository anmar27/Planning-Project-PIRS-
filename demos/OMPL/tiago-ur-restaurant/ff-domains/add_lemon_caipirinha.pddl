(define (domain cocktail-preparation)
  (:requirements :strips :typing)
  
  (:types
    location    ; Different locations on the bar counter
    robot       ; Robots involved in the task
    ingredient  ; Ingredients like limon
    glass       ; Container for the cocktail
    cocktail    ; The final product
  )

  (:predicates
    ; Location-based predicates
    (at ?obj - (either ingredient glass cocktail) ?loc - location)
    (robot_at ?r - robot ?loc - location)
    (is_bar_counter ?loc - location)
    (is_handover_location ?loc - location)
    
    ; Object state predicates
    (holding ?r - robot ?obj - (either ingredient glass cocktail))
    (empty_hand ?r - robot)
    (is_empty ?g - glass)
    
    ; Cocktail preparation predicates
    (has_limon ?c - cocktail)
    (is_prepared ?c - cocktail)
    
    ; Glass and ingredient relations
    (ingredient_in_glass ?i - ingredient ?g - glass)
    (is_limon ?i - ingredient)
    
    ; Robot capability predicates
    (can_reach ?r - robot ?loc - location)
    (can_prepare_cocktails ?r - robot)
  )

  (:action pick
    :parameters (?r - robot ?obj - (either ingredient glass cocktail) ?loc - location)
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

  (:action place
    :parameters (?r - robot ?obj - (either ingredient glass cocktail) ?loc - location)
    :precondition (and
      (robot_at ?r ?loc)
      (holding ?r ?obj)
      (can_reach ?r ?loc)
    )
    :effect (and
      (at ?obj ?loc)
      (not (holding ?r ?obj))
      (empty_hand ?r)
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

  (:action add_limon
    :parameters (?r - robot ?i - ingredient ?g - glass ?loc - location)
    :precondition (and
      (robot_at ?r ?loc)
      (at ?g ?loc)
      (holding ?r ?i)
      (is_limon ?i)
      (is_empty ?g)
      (can_prepare_cocktails ?r)
      (is_bar_counter ?loc)
    )
    :effect (and
      (not (is_empty ?g))
      (ingredient_in_glass ?i ?g)
      (not (holding ?r ?i))
      (empty_hand ?r)
    )
  )

  (:action prepare_cocktail
    :parameters (?r - robot ?g - glass ?c - cocktail ?loc - location)
    :precondition (and
      (robot_at ?r ?loc)
      (at ?g ?loc)
      (can_prepare_cocktails ?r)
      (exists (?i - ingredient)
        (and 
          (ingredient_in_glass ?i ?g)
          (is_limon ?i)
        )
      )
    )
    :effect (and
      (is_prepared ?c)
      (has_limon ?c)
    )
  )
)