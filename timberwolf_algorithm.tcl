# implemention of timberwolf algorithm #

# 1:

set cells [get_db insts -if {.base_cell.name == "MX2X1"}]


# 2 :
proc FINDX1 {cell} {
  set x1 [get_rect -llx [get_db $cell .place_halo_bbox]]
  return $x1
}
  
proc FINDX2 {cell} {
  set x2 [get_rect -urx [get_db $cell .place_halo_bbox]]
  return $x2
}
  
proc FINDY1 {cell} {
  set y1 [get_rect -lly [get_db $cell .place_halo_bbox]]
  return $y1
}
  
proc FINDY2 {cell} {
  set y2 [get_rect -ury [get_db $cell .place_halo_bbox]]
  return $y2
}

proc ManhattanDistance {point1 point2} {
  set x1_point1 [get_rect -llx [get_db $point1 .bbox]]
      set x1_point2 [get_rect -llx [get_db $point2 .bbox]]
  set y1_point1 [get_rect -lly [get_db $point1 .bbox]]
  set y1_point2 [get_rect -lly [get_db $point2 .bbox]]
    set dx [expr {int($x1_point2 - $x1_point1)}]
      set dy [expr {int($y1_point2 - $y1_point1)}]
      set distance [expr {int(abs($dx) + abs($dy))}]
    return $distance
} 
  
proc CalculateOverlapArea {rect1 rect2} {
  set x1_rect1 [FINDX1 $rect1]
    set x2_rect1 [FINDX2 $rect1]
  set y1_rect1 [FINDY1 $rect1]
  set y2_rect1 [FINDY2 $rect1]
  set x1_rect2 [FINDX1 $rect2]
      set x2_rect2 [FINDX2 $rect2]
  set y1_rect2 [FINDY1 $rect2]
  set y2_rect2 [FINDY2 $rect2]
      set x_overlap [expr {int(min($x2_rect1, $x2_rect2) - max($x1_rect1, $x1_rect2))}]
      set y_overlap [expr {int(min($y2_rect1, $y2_rect2) - max($y1_rect1, $y1_rect2))}]

      if {$x_overlap <= 0 || $y_overlap <= 0} {
          return 0
      }

      set overlap_area [expr {int($x_overlap * $y_overlap)}]
      return $overlap_area
}

proc Weight {} {
    # Calculate the Manhattan distance sum of nets a, b, and z
    set sum_distances 0
    for {set i 0} {$i < 4} {incr i} {
      lappend a [get_db nets -if {.name == "a[$i]"}]
  lappend b [get_db nets -if {.name == "b[$i]"}]
  lappend z [get_db nets -if {.name == "z[$i]"}]
    }
   

    # Calculate Manhattan distance for bus a
    for {set i 0} {$i < 4} {incr i} {
        set point_a [lindex $a $i]
        set point_z [lindex $z $i]
        set distance_a_z [ManhattanDistance $point_a $point_z]
        set sum_distances [expr {int($sum_distances + $distance_a_z)}]
    }

    # Calculate Manhattan distance for bus b
    for {set i 0} {$i < 4} {incr i} {
        set point_b [lindex $b $i]
        set point_z [lindex $z $i]
        set distance_b_z [ManhattanDistance $point_b $point_z]
        set sum_distances [expr {int($sum_distances + $distance_b_z)}]
    }

  set manhattan_sum [expr {int($sum_distances)}]

    
  # Calculate the area of overlaps between muxes

  # Calculate overlap areas between muxes
  set overlap_areas {}
  set sum_overlap_areas 0
  set cells [get_db insts -if {.base_cell.name == "MX2X1"}]
  for {set i 0} {$i < 4} {incr i} {
        for {set j [expr {$i + 1}]} {$j < 4} {incr j} {
            set mux1 [lindex $cells $i]
            set mux2 [lindex $cells $j]

            set overlap_area [CalculateOverlapArea $mux1 $mux2]
            lappend overlap_areas [list mux$i:mux$j $overlap_area]
      incr sum_overlap_areas $overlap_area
      }
  }

      set mux_overlap_area [expr {int($sum_overlap_areas)}]


      # Calculate the area of cells outside the boundary
      # Define the boundary of the design {x1 x2 y1 y2}
  set x1 2.7
  set x2 202.8
  set y1 2.7
  set y2 202.8

  
  
  # Calculate the area of cells outside the boundary
  set outside_area 0
  set cells [get_db insts -if {.base_cell.name == "MX2X1"}]
  for {set i 0} {$i < 4} {incr i} {
    set cell [lindex $cells $i]
    set x1_cell [FINDX1 $cell]
        set x2_cell [FINDX2 $cell]
    set y1_cell [FINDY1 $cell]
    set y2_cell [FINDY2 $cell]
    set x_overlap [expr {int(min($x2_cell, $x2) - max($x1_cell, $x1))}]
        set y_overlap [expr {int(min($y2_cell, $y2) - max($y1_cell, $y1))}]

        if {$x_overlap <= 0 || $y_overlap <= 0} {
            set cell_area [expr {int(($x2_cell - $x1_cell) * ($y2_cell - $y1_cell))}]
            incr outside_area $cell_area
        } else {
            set inside_area [expr {int($x_overlap * $y_overlap)}]
            set cell_area [expr {int(($x2_cell - $x1_cell) * ($y2_cell - $y1_cell))}]
            set outside_area [expr {int($outside_area + $cell_area - $inside_area)}]
        }
  }
  
  # Calculate the weight
  set weight [expr {int($manhattan_sum + $mux_overlap_area + $outside_area)}]
  return $weight
}

  

# 3 :

# Function to perform M1 operation (Displace a module to a new location)
proc M1 {} {

    # Generate random coordinates for the new location
    set new_x1 [expr {int(rand() * 200)}]
    set new_y1 [expr {int(rand() * 200)}]
    set new_x2 [expr {int(rand() * 200)}]
    set new_y2 [expr {int(rand() * 200)}]

    # Displace the module to the new location
    set current_placement [list $new_x1 $new_y1 $new_x2 $new_y2]
    return $current_placement
}

# Function to perform M2 operation (Interchange two modules)
proc M2 {current_placement_1 current_placement_2} {

    # Swap the coordinates of the two modules
    
    set current_placement1 [lindex $current_placement_2]
    set current_placement2 [lindex $current_placement_1]
}

# Function to move to a neighbor solution
proc MoveNeighborSolution {current_placement i j} {
    set random_move [expr {rand()}]
  
          if {$random_move < 0.8} {
              ;# Choose move of type M1 (Displace a module)
              set placement [M1]
          } else {
              ;# Choose move of type M2 (Interchange two modules)
              set placement [M2 [lindex $current_placement $i] [lindex $current_placement $j] ]
          }
    ;# Return the new placement after the move
    return $placement
}

# Function to calculate the weight of a neighbor solution
proc WeightNeighbor {neighbor_placement} {
    ;# Set the placement to the neighbor_placement
    ;# Calculate and return the weight of the neighbor placement
    return [Weight]
}

# Define the initial placement of the muxes and cells
set initial_placement {}
set cells [get_db insts -if {.base_cell.name == "MX2X1"}]
for {set i 0} {$i < 4} {incr i} {
  lappend initial_placement [get_db [lindex $cells $i] .place_halo_bbox]
}


# Define the bounding box for the design
set design_bbox {2.7 202.8 2.7 202.8}

# Define the cooling schedule for simulated annealing
set initial_temperature 100.0
set cooling_rate 0.03

# Perform the simulated annealing optimization

set temperature $initial_temperature
set current_placement $initial_placement
set current_weight [Weight]

set startTime [clock clicks -milliseconds]

    while {$temperature > 1} {
      for {set i 0} {$i <= 4} {incr i} {
        for {set j [expr {$i + 1}]} {$j < 4} {incr j} {
            set neighbor_placement [MoveNeighborSolution $current_placement $i $j]
            set neighbor_weight [WeightNeighbor $neighbor_placement]

            set weight_difference [expr {$neighbor_weight - $current_weight}]

            if {$weight_difference <= 0} {
                  set current_placement $neighbor_placement
                set current_weight $neighbor_weight
            } else {
                  set probability [expr {exp(-$weight_difference / $temperature)}]
                  set random_value [expr {rand()}]

                if {$random_value < $probability} {
                    set current_placement $neighbor_placement
                    set current_weight $neighbor_weight
                }
            }
        }
  }
  set temperature [expr {$temperature - $cooling_rate}]
}
    
set endTime [clock clicks -milliseconds]
set Timing [expr {$endTime - $startTime}]
# Print the final weight and placement and timing
puts "Final weight: $current_weight"
puts "Final placement: $current_placement"
puts "Timing : $Timing"


# 4 :


#timing for 5 muxes : 153355 [ms] ~ 2.5 [mins]
#timing for 2 muxes : 4432 [ms] ~ 0.07 [mins]
#timing for 3 muxes : 21838 [ms] ~ 0.364 [mins]
#timing for 4 muxes : 64340 [ms] ~ 1.07 [mins]

#after graphing the points i got , i found that the time complexity is not linear.


#5

#for 4 muxes :

#weight of my solution before using "place_opt_design" command : 2415
#weight after using "place_opt_design" command : 1158

#the weight of the solution after using "place_opt_design" , is much better than mine ,
#thats heavily due to the fact that my solution does a random placement for the cells and nets , and keeps itirating until it gets to a minimum ,
#while with "place_opt_design" , the design is automatically routed and placed to an optimal placement with minimal distances between cells and nets , minimal area out of boundary and minimal overlapping area.  





