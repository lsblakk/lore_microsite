###

                            cccccccccccccccccccccc                             
                       ccccccccccccccccccccccccccccccccc                       
                   ccccccccccccccccccccccccccccccccccccccccc                   
                ccccccccccccccccccccccccccccccccccccccccccccccc                
             cccccccccccccccccccccccccccccccccccccccccccccccccccc              
           cccccccccccccccccccccccccccccccccccccccccccccccccccccccc            
         cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc          
        ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc        
      ccccccccccccccccccccccccccccccccccccccccccc     cccccccccccccccccc       
     ccccccccccccc           cccccccccccccccc             cccccccccccccccc     
    ccccccccccccccccc   ccccccccccccccccccc     cccccccc    ccccccccccccccc    
   cccccccccccccccccc   cccccccccccccccccc    cccccccccccc   ccccccccccccccc   
  ccccccccccccccccccc   cccccccccccccccccc   cccccccccccccc   cccccccccccccc   
 cccccccccccccccccccc   ccccccccccccccccc   ccccccccccccccc   ccccccccccccccc  
 cccccccccccccccccccc   cccccccccccccccccc   cccccccccccccc   cccccccccccccccc 
ccccccccccccccccccccc   cccccccccc   ccccc    cccccccccccc   ccccccccccccccccc 
ccccccccccccccccccccc   cccccccccc   cccccc     cccccccc    cccccccccccccccccc 
cccccccccccccccccc                   cccccccc             ccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc    ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc                 ccccccc                  ccccccccccccccccccc
ccccccccccccccccccccc   ccccccccc    cccccccc   ccccccccc   cccccccccccccccccc 
ccccccccccccccccccccc   ccccccccccc  cccccccc   ccccccccc   cccccccccccccccccc 
 cccccccccccccccccccc   cccccccccc   cccccccc   cccccccccccccccccccccccccccccc 
 cccccccccccccccccccc               ccccccccc        cccccccccccccccccccccccc  
  ccccccccccccccccccc   cccc    ccccccccccccc   cccccccccccccccccccccccccccc   
   cccccccccccccccccc   ccccc    cccccccccccc   ccccccccc   cccccccccccccccc   
    ccccccccccccccccc   ccccccc   ccccccccccc   ccccccccc   ccccccccccccccc    
     ccccccccccccc      cccccccc     ccccc                  cccccccccccccc     
      cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc       
        ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc        
         cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc          
           cccccccccccccccccccccccccccccccccccccccccccccccccccccccc            
             cccccccccccccccccccccccccccccccccccccccccccccccccccc              
                ccccccccccccccccccccccccccccccccccccccccccccccc                
                   ccccccccccccccccccccccccccccccccccccccccc                   
                       ccccccccccccccccccccccccccccccccc                       
                            cccccccccccccccccccccc            


We're hiring awesome people to build awesome things (like this) - http://lore.com/jobs                            

Developed by: Jim Grandpre (@jimtla)
Designed by: Matt Delbridge (@matt_delbridge), Aaron Carambula (@carambula), Joseph Cohen (@josephcohen)
###

# Thanks to Eric Moller for this requestAnimationFrame polyfill
# Converted from http://paulirish.com/2011/requestanimationframe-for-smart-animating/
do () ->
    lastTime = 0;
    vendors = ['ms', 'moz', 'webkit', 'o'];
    for vendor in vendors
        if window.requestAnimationFrame
            break
        window.requestAnimationFrame = window[vendor+'RequestAnimationFrame'];
        window.cancelAnimationFrame = 
          window[vendors+'CancelAnimationFrame'] || window[vendors+'RequestCancelAnimationFrame'];

    if !window.requestAnimationFrame
        window.requestAnimationFrame = (callback) ->
            currTime = new Date().getTime()
            timeToCall = Math.max(0, 16 - (currTime - lastTime))
            id = window.setTimeout (() -> callback timeToCall), timeToCall 
            lastTime = currTime + timeToCall
            return id

    if !window.cancelAnimationFrame
        window.cancelAnimationFrame = (id) -> clearTimeout id
# End requestAnimationFrame polyfill


dist2 = (p0, p1) ->
    (p0.x - p1.x) * (p0.x - p1.x) + (p0.y - p1.y) * (p0.y - p1.y)

# Scaled random centered on zero - just for convenience
random = -> (Math.random() - .5) * .1

# Clone an acyclic array or object
deep_clone = (target) ->
    if target instanceof Array
        (t for t in target)
    else if typeof target == 'object'
        res = {}
        for k, v of target
            res[k] = deep_clone v
        res
    else
        target

#The Dot's! Responsible for animating and drawing themselves
class Dot
    constructor: (@target,  @screen) ->
        @target.background_image = null
        @actual = deep_clone @target
        @current_background = null

        @velocity = {x: 0, y: 0}

        @node = $ '<div class="dot"><div class="inner-dot"></div></div>'
        @screen.find('.dots').append @node
        @inner_node = @node.find('.inner-dot')
    set_goal: (goal) ->
        @target = _(deep_clone goal).defaults(@target)
        if !goal.background_image
            @target.background_image = null


    do_frame: (scale) ->
        previous = deep_clone @actual
        @animate()
        @draw scale, previous
    animate: ->
        if @target.absolute
            @actual = deep_clone @target
        else
            speed = .004

            # Apply Friction
            @velocity.x *= .9
            @velocity.y *= .9


            # Spring physics! Accelerate towards the target position 
            dx = @target.position.x - @actual.position.x
            dy = @target.position.y - @actual.position.y

            @velocity.x += dx*speed
            @velocity.y += dy*speed


            # Do the movement
            @actual.position.x += @velocity.x
            @actual.position.y += @velocity.y


            # Animate the color
            dcol = (@target.color[i] - c for c, i in @actual.color)
            dist = Math.sqrt dcol[0]*dcol[0] + dcol[1]*dcol[1] + dcol[2]*dcol[2]
            for c, i in dcol
                if dist > 4
                    @actual.color[i] += c/dist*4
                else
                    @actual.color[i] += c

            # Animate scalars
            for scalar in ['radius', 'opacity', 'outer_opacity', 'outer_padding']
                dv = @target[scalar] - @actual[scalar]
                abs_dv = Math.abs dv
                if abs_dv > speed
                    dv = dv/abs_dv * speed
                @actual[scalar] += dv

            # Set z-index
            @actual.z_index = @target.z_index

            # Handle immediate transitions (for abrupt changes)
            if @target.immediate
                for i in @target.immediate
                    @actual[i] = @target[i]

            @actual.background_image = deep_clone @target.background_image
    draw: (scale, previous) ->
        # Update the inner dot, if it has changed
        outer_radius = @actual.radius + @actual.outer_padding
        inner_changed = false
        inner_changes = {}

        compute_inner = 
            top: (t) -> (t.outer_padding/2 * scale)
            left: (t) -> (t.outer_padding/2 * scale)
            width: (t) -> t.radius * scale
            height: (t) -> t.radius * scale
            background: (t) ->
                color = _(t.color).map (c) -> parseInt c
                "rgba(#{color.join(',')},#{t.opacity})"

        for k,v of compute_inner
            prev = v(previous)
            act = v(@actual)
            if prev != act
                inner_changed = true
                inner_changes[k] = act

        if inner_changed
            @inner_node.css inner_changes

        # Update the outer dot (it almost always changes, so it's not worth checking)
        node_changes = 
            top:    (@actual.position.y - outer_radius/2) * scale
            left:   (@actual.position.x - outer_radius/2) * scale
            width:  (@actual.radius + @actual.outer_padding) * scale
            height: (@actual.radius + @actual.outer_padding) * scale
            'z-index': @actual.z_index

        if !@target.background_image?
            color = _(@actual.color).map (c) -> parseInt c
            node_changes.background = "rgba(#{color.join(',')},#{@actual.outer_opacity})"
            node_changes.opacity = 1
            @current_background = null
        else
            background = @actual.background_image
            if @current_background != background.image
                node_changes.background = "url(#{background.image}) no-repeat"
                @current_background = background.image
            posx = parseInt((background.position.x - background.size/2) * scale - node_changes.left)
            posy = parseInt((background.position.y - background.size/2) * scale - node_changes.top)

            node_changes['background-position'] = "#{posx}px #{posy}px"
            node_changes['background-size'] = parseInt background.size * scale
            node_changes['-moz-background-size'] = parseInt background.size * scale
            node_changes.opacity = @actual.outer_opacity
        @node.css node_changes

$ ->
    screen = $('.screen')

    console.log $('html').attr 'class'

    ck_logo_start = -> minor_dimension * .1

    dots = []
    make_dot = (args) ->
        args.outer_padding ?= 0
        args.outer_opacity ?= 0
        args.absolute ?= false
        new Dot(args, screen)

    get_points = (frame_time, dtim, elapsed_time) ->
        _.flatten(s.get_points(frame_time, dtim, elapsed_time) for s in current_page.shapes)

    set_goals = (points) ->
        for i in [0...points.length]
            points[i].z_index ?= 1
            points[i].outer_padding ?= 0
            points[i].outer_opacity ?= 0
            points[i].absolute ?= false
            points[i].immediate ?= []
            dots[i].set_goal points[i]


    social = $('.social')
    new_page = (points) ->
        if current_page_index > 1
            ck_logo.css opacity: 0
        else    
            ck_logo.css opacity: 1

        if current_page_index == pages.length - 1
            social.addClass 'visible'
            lore_logo.addClass 'visible'
            next_page_button.fadeOut 500
            first_page_button.addClass 'visible'
        else
            social.removeClass 'visible'
            lore_logo.removeClass 'visible'
            next_page_button.fadeIn 500
            first_page_button.removeClass 'visible'

        these_dots = _.clone(dots)
        dots = 
            for point in points
                if these_dots.length > 0
                    mindist = Infinity
                    mini = -1
                    for dot, i in these_dots
                        dist = dist2 dot.actual.position, point.position
                        if dist < mindist
                            mindist = dist
                            mini = i
                    d = these_dots[mini]
                    v = these_dots.pop()
                    these_dots[mini] = v if mini < these_dots.length
                    d
                else
                    make_dot point

        for dot in these_dots # Orphaned Dots
            dots.push dot
            dot.set_goal 
                opacity: 0
                radius: 0
                outer_padding: 0
                outer_opacity: 0


    # ----------------------- Shapes -----------------------
    ck_logo_shape =  ->
        get_points: (time, dtim, elapsed_time) ->
            ck_logo.css top: Math.min((elapsed_time - 1000)/200, 1) * ck_logo_start()
            []

    decompose_ck = ->
        radius = .15
        dot_count = 20
        dot_radius = 0.08
        start_colors = [[74, 39, 62], [54, 125, 186],[54, 125, 186], [93, 141, 72], [239, 158, 24], [191, 41, 36] ]
        final_color = [114, 84, 105]
        position = {x: .5, y: .5}


        immediate = []
        get_points: (time, dtim, elapsed_time) ->
            if elapsed_time == 0
                immediate = (true for i in [0...dot_count])

            _.defer -> ck_logo.css opacity: 0
            logo_position = 
                x: .5
                y: (ck_logo_start() + ck_logo.height()/2 - 15)/minor_dimension


            for p in [0...dot_count]
                ang = 2 * Math.PI * p/6
                if p * 150 + (p % 7) * 100 < elapsed_time - 800
                    position:
                        x: position.x + radius * Math.cos(ang) + random() * .3
                        y: position.y + radius * Math.sin(ang) + random() * .3 
                    color: final_color
                    radius: dot_radius
                    opacity: 1
                else if p * 50 < elapsed_time - 700 
                    v = 
                        position:
                            x: position.x + radius * Math.cos(ang) * 2 + random()
                            y: position.y + radius * Math.sin(ang) * 2 + random()
                        color: start_colors[p % start_colors.length]
                        radius: dot_radius * .3 #+ random()
                        opacity: .5 + random()#opacity 
                    if immediate[p]
                        v.immediate = ['opacity', 'color']
                        immediate[p] = false
                    else
                        v.immediate = []
                    v
                else if p * 50 < elapsed_time - 100
                    size = .15
                    grid = 4
                    grid_ind = (p * 13) % 20 
                    position: 
                        x: logo_position.x + (grid_ind % grid) * size/(grid - 1) - size/2
                        y: logo_position.y + (parseInt(grid_ind/grid)) * size/(dot_count/grid - 1) - size/2
                    color: [255,255,255] #start_colors[p % start_colors.length]
                    radius: dot_radius * .4
                    opacity: 0#.5 + random() * 5
                    outer_opacity: .1
                    background_image: 
                        position: logo_position
                        size: size
                        image: '/microsite_static/coursekit_logo.png'                   
                else
                    size = .15
                    grid = 4
                    grid_ind = (p * 13) % 20 
                    position: 
                        x: logo_position.x + (grid_ind % grid) * size/(grid - 1) - size/2
                        y: logo_position.y + (parseInt(grid_ind/grid)) * size/(dot_count/grid - 1) - size/2
                    color: [255,255,255]
                    radius: size/dot_count * 10
                    opacity: 0
                    outer_opacity: 1
                    absolute: true
                    background_image: 
                        position: logo_position
                        size: size
                        image: '/microsite_static/coursekit_logo.png'





    clump = (clump_position, size, color, radius, clump_max_radius, orbit_varience, grow, background, rotation_rate) -> 
        color ?= [84, 147, 195]
        size ?= 7
        radius ?= {constant: .01, varience: 150}
        clump_max_radius ?= 999
        orbit_varience ?= .014
        grow ?= false
        rotation_rate ?= 1

        outer_opacity = .8
        opacity = .8
        if background?
            opacity = 0

        points = []
        make_points = ->
            points = 
                for i in [0...size]
                    radius_seed = Math.random() * .1
                    r = radius_seed * radius_seed * radius_seed * radius.varience + radius.constant

                    ang: 2*Math.PI*i/size + random()
                    velocity: random() * rotation_rate
                    orbitx: Math.min(Math.sqrt(Math.random() * orbit_varience) + r, clump_max_radius) - r
                    orbity: Math.min(Math.sqrt(Math.random() * orbit_varience) + r, clump_max_radius) - r
                    color: color
                    radius: r
                    background_image: background
                    opacity: opacity * (Math.random() * .5 + .5)
                    outer_opacity: outer_opacity * (Math.random() * .5 + .5) 

        get_points: (time, dtim, elapsed_time) ->
            if elapsed_time == 0
                make_points()

            for p, ind in points
                p.ang += dtim/8 * p.velocity
                if elapsed_time > 3200 and grow
                    if ind > 0
                        p.outer_opacity -= .01
                    else 
                        if p.radius < .32
                            p.radius += .2
                        p.orbitx -= .1
                        p.orbity -= .1
                        p.orbitx = Math.max(0, p.orbitx)
                        p.orbity = Math.max(0, p.orbity)
                        if elapsed_time > 4000
                            p.outer_opacity += .005
                        else
                            p.outer_opacity = .2
                else
                    p.orbitx += random()*.01
                    p.orbity += random()*.01

                if grow and p.radius < .15 and time % 4 == 0
                    p.radius += Math.random() * .001

                p.position = 
                    x: clump_position.x + p.orbitx * Math.cos(p.ang)
                    y: clump_position.y + p.orbity * Math.sin(p.ang)
                p


    sharing = (position) -> 
        radius = .4
        pins = 3
        color = [122, 161, 106]
        opacity = .7

        size = 18
        moving_points = 
            for i in [0...size]
                ang: 2*Math.PI*i/size + random()
                velocity: Math.sqrt(Math.random() + .2) * .015 * (if random() > 0 then 1 else - 1)
                orbit: random() + radius
                color: color
                radius: (.1 + random()) * .3 
                opacity: opacity + random() * 5
                'z-index': if random() > 0 then 60 else 40

        pin_offsets = ({x: 0, y: 0} for i in [0...pins])

        get_points: (time, dtim, elapsed_time) ->
            points = []

            for p in [0...pins]
                ang = 2*Math.PI*p/pins - Math.PI/32

                pin_offsets[p].x += random() * .1
                pin_offsets[p].y += random() * .1
                pin_offsets[p].x *= .8
                pin_offsets[p].y *= .8
                points.push
                    opacity: 1
                    outer_opacity: 1
                    radius: .2
                    position: 
                        x: Math.cos(ang)*radius + position.x + pin_offsets[p].x
                        y: Math.sin(ang)*radius + position.y + pin_offsets[p].y
                    color: color

            for p, i in moving_points
                near_pin = ((p.ang % (2*Math.PI)) + Math.PI/32)/(2*Math.PI)*pins
                ang =
                    if (elapsed_time + 5000*i/moving_points.length) > 5500
                        p.opacity += random() * .2
                        distance = Math.abs(Math.abs((near_pin - parseInt near_pin)) - .5) * 4

                        p.ang += dtim/10 * p.velocity * .8/(distance*distance*distance + .1)
                        p.ang
                    else
                        parseInt(near_pin)/pins * 2 * Math.PI - Math.PI/32


                p.position =
                    x: position.x + p.orbit * Math.cos(ang)
                    y: position.y + p.orbit * Math.sin(ang)
                points.push p
            points


    infinity = (center) ->
        radius = .2
        color = [236, 156, 39]
        opacity = .8
        dot_radius = 0.1

        size = 21
        points = []
        generate_points = ->
            for i in [0...size]
                ang: 4*Math.PI*i/size
                color: color
                radius: (.1 + random()) * .3
                opacity: opacity + random() * 2

        get_points: (time, dtim, elapsed_time) ->
            if elapsed_time == 0
                points = generate_points()

            for p, i in points
                offset = 
                    if p.ang > 2*Math.PI
                        ang = -(2*Math.PI - p.ang) + Math.PI
                        radius
                    else
                        ang = -p.ang
                        -radius
                p.position = 
                    x: center.x + radius * Math.cos(ang) + offset
                    y: center.y + radius * Math.sin(ang)

                p.ang += dtim/500
                p.ang %= Math.PI*4
                p

    animated_circle = ({duration, size, radius, start, end, rotation, dot_radius, color, opacity, outer_padding, outer_opacity}) ->
        max_dots = 6
        color ?= [236, 156, 39]
        opacity ?= .8
        duration ?= 1000
        outer_padding ?= 0
        outer_opacity ?= 0

        points = []
        generate_points = ->
            for i in [0...size]
                ang: 2*Math.PI*i/size
                color: color
                radius: dot_radius
                opacity: opacity + random() * 2
                outer_padding: outer_padding
                outer_opacity: outer_opacity

        get_points: (time, dtim, elapsed_time) ->
            if elapsed_time == 0
                points = generate_points()

            t = Math.max(Math.min(elapsed_time/duration, 1), 0)
            for p, i in points
                p.position = 
                    x: (end.x - start.x) * t + start.x + radius * Math.cos(p.ang)
                    y: (end.y - start.y) * t + start.y + radius * Math.sin(p.ang)

                p.ang += dtim/400 * rotation
                p.ang %= Math.PI*4
                p

    point = ({position, dot_radius, color, opacity, outer_padding, outer_opacity, z_index}) ->
        color ?= [236, 156, 39]
        opacity ?= .8
        outer_padding ?= 0
        outer_opacity ?= 0
        z_index ?= 1


        get_points: (time, dtim, elapsed_time) ->
            color: color
            radius: dot_radius
            opacity: opacity
            position: position
            outer_opacity: outer_opacity
            outer_padding: outer_padding
            z_index: z_index

    tree = ->
        num_dots = 42
        color = [230, 109, 37]
        outer_padding = .01
        outer_opacity = .1

        split_time = (time, level) -> time + 200 + Math.random() * 1000 * Math.sqrt(level)

        points = null
        out_points = null
        reset_points = (time) ->
            out_points = []
            points = []
            points.push
                color: color
                radius: .08
                opacity: 1
                outer_padding: outer_padding
                outer_opacity: outer_opacity
                position: {x: .5, y: .2}
                children: []
                split_time: split_time time, 1
                level: 1
            out_points.push points[0]

            for p in [1...num_dots]
                np = deep_clone(points[0])
                np.radius = .01
                np.opacity = .1
                np.children = []
                points[0].children.push np
                out_points.push np

        initialize_child = (time, parent, child, pivot, left) ->
            child.level = parent.level + 1
            child.position = 
                x: parent.position.x + (Math.random() * .3 + .7) * (if left then -1 else 1)/(child.level * child.level)
                y: parent.position.y + .08 + Math.random() * .08
            child.split_time = split_time time, child.level
            child.children = 
                if left
                    parent.children[1...pivot]
                else
                    parent.children[pivot+1...]
            child.radius = (.08 + random())/Math.sqrt(child.level)
            child.opacity = (.8 + random())

            for c in child.children
                c.position = child.position
            points.push child


        get_points: (time, dtim, elapsed_time) ->
            if elapsed_time == 0
                reset_points time

            for p in points
                p.position.x += random() * .08
                p.position.y += random() * .08
                if p.split_time < time and p.children.length >= 2
                    l = parseInt p.children.length/2
                    initialize_child time, p, p.children[0], l, true
                    initialize_child time, p, p.children[l], l, false
                    p.children = []

            out_points
    # --------------- END SHAPES ----------------



    pages = [
        {shapes: [ck_logo_shape()], text: '<span class="smaller"><b>Coursekit is now Lore.<br>Same Company, New Name.</b><br>This is why we made the change.</span>'}
        {shapes: [decompose_ck()], text: 'Coursekit started<br>as a toolkit for<br>courses.'}
        {shapes: [clump({x: .4, y: .7}), clump({x: .1, y: .3}), clump({x: .8, y: .4})], text: 'Courses became<br>communities of<br>learners.'}
        {shapes: [sharing({x: .5, y: .5})], text: 'We&rsquo;ve seen<br>that people learn<br>by sharing.'}
        {shapes: [infinity({x: .5, y: .5})], text: 'Our mission is to<br>connect the world&rsquo;s<br>learners and<br>educators.'}
        {shapes: [
            animated_circle
                size: 10
                radius: .06
                start: {x: .3, y: .5}
                end: {x: .5, y: .5}
                dot_radius: .02
                rotation: -1
            animated_circle
                size: 10
                radius: .12
                start: {x: .7, y: .5}
                end: {x: .5, y: .5}
                dot_radius: .03
                rotation: 1
            point
                position: {x: .5, y: .5}
                dot_radius: .03
            ], text: 'We need a name<br>that reflects our<br>ambitions.'}
        {shapes: [
            tree()
            ], text: 'Lore means<br>knowledge shared<br>between people.'}           
        {shapes: [
            clump({x: .5, y: .5}, 42, [225, 15, 23], {constant: .03, varience: 50}, .4, .06)
            ], text: "That&rsquo;s what we<br>are about."}                      
        {shapes: [
            clump({x: .5, y: .5}, 42, [225, 15, 23], {constant: .04, varience: 50}, .4, .04, true, {image: '/microsite_static/lore_logo.png', position: {x: .5, y: .5}, size: .3}, .3)
            ], text: ""}
    ]


    # Manage the pages
    last_page = null
    current_page_index = 0 
    current_page = pages[current_page_index]
    page_count = pages.length

    text_blocks = []
    for {text}, i in pages
        text_blocks.push
            node: $("<span class='caption'>#{text}</span>").appendTo(screen)
            position: i

    # Handle screen size/resizing
    browser_height = 0
    browser_width = 0
    minor_dimension = 0

    ck_logo = screen.find '.coursekit-logo'
    lore_logo = screen.find '.lore-logo'

    page_height = 0
    $(window).resize ->
        browser_height = $(window).height()
        page_height = browser_height * 5
        browser_width = $(window).width()

        minor_dimension = Math.min(browser_width, browser_height)
        screen.width minor_dimension
        screen.height minor_dimension

        screen.css 
            top: (browser_height - minor_dimension)/2

        screen.find('.caption').css
            'font-size': Math.min(minor_dimension/12, 85)
            left: .1 * minor_dimension

        screen.find('.smaller').css
            'font-size': Math.min(minor_dimension/20, 60)

        holder = $('.holder')
        holder.height page_height * page_count - page_height + browser_height - 100

        logos = [{logo: ck_logo, aspect: 329/380, scale: .15}, {logo: lore_logo, aspect: 1, scale: .3}]
        for {logo, aspect, scale} in logos
            width = minor_dimension * scale
            logo.css 
                width: width 
                height: minor_dimension * scale / aspect
                left: minor_dimension/2 - width/2

        lore_logo.css
            top: minor_dimension/2 - lore_logo.height()/2

    $(window).resize()


    # Scrolling
    # Switch pages when you move by 1/3 of a page
    # To prevent flickering while in the middle third between pages
    # We keep track of weather we are in that third or not
    # And only switch pages if we were not previously in the third
    scroll_momentum = 0
    last_scroll = $(window).scrollTop()
    last_scroll_time = 0
    in_third = false
    $(window).scroll (e, triggered) ->
        scroll_top = $(window).scrollTop() 
        current_page_height = page_height * current_page_index 
        portion = page_height/3

        if scroll_top > current_page_height + 2*portion and pages[current_page_index + 1]? 
            in_third = false
        else if scroll_top < current_page_height - 2*portion and pages[current_page_index + 1]? 
            in_third = false

        if scroll_top > current_page_height + portion and pages[current_page_index + 1]?
            if not in_third
                current_page_index++
                current_page = pages[current_page_index]
                in_third = true
        else if scroll_top < current_page_height - portion and pages[current_page_index - 1]?
            if not in_third
                current_page_index--
                current_page = pages[current_page_index]
                in_third = true
        else  
            in_third = false


        for {node, position} in text_blocks
            target = page_height * position - node.height()/3
            #node.css top: (target - scroll_top) * (target - scroll_top) * (target - scroll_top)
            diff = (target - scroll_top)*.7/(page_height)
            sign = if diff > 0 then 1 else - 1
            node.css top: diff * diff * sign * page_height + minor_dimension/3
            #node.css top: (target - scroll_top) + page_height/3
        last_scroll = scroll_top

    target_page = 0
    last_mousewheel = 0
    $(window).bind 'mousewheel', (e, delta) ->
        console.log delta
        now = +new Date()
        if now - last_mousewheel < 1500 or Math.abs(delta) < .4
            return
        last_mousewheel = now

        momentum = .8
        scroll_top = $(window).scrollTop() 
        if (delta) > 0
            target_page = parseInt(scroll_top/page_height + .5) - 1
        else 
            target_page = parseInt(scroll_top/page_height + .5) + 1
        #scroll_momentum = Math.max(Math.min(scroll_momentum, .8), -.8)
        last_scroll_time = +new Date()
            
    $(window).scroll()


    # Jump to next page with button or keyboard
    next_page_button = screen.find('.next-page').click ->
        scroll_top = $(window).scrollTop()
        target_page = parseInt(scroll_top/page_height + .5) + 1
        return false

    first_page_button = screen.find('.first-page').click ->
        target_page = 0
        return false

    screen.click ->
        scroll_top = $(window).scrollTop() 
        target_page = parseInt(scroll_top/page_height + .5) + 1

    $(document).bind 'keydown', (e) ->
        scroll_top = $(window).scrollTop() 
        if e.which in [37, 38]
            target_page = parseInt(sroll_top/page_height + .5) - 1
            false
        else if e.which in [39, 40, 32, 13, 9]
            target_page = parseInt(scroll_top/page_height + .5) + 1
            false

    # Handle the animation frames
    frame_count = 0
    otim = + new Date()
    start_time = null
    last_below = null
    scroll_paused = 0
    last_sign = null
    do_frame = () ->
        frame_count++
        time = +new Date()
        dtim = time - otim
        otim = time

        if scroll_paused + 100 > time
            scroll_momentum = 0
        if frame_count % 1 == 0
            last_scroll = $(window).scrollTop()
            # Spring physics to bring the scroll position towards a page
            direction = if scroll_momentum > 0 then 1 else -1
            #target = parseInt(last_scroll/page_height + .5 + (direction * .4))
            distance_to_target = target_page - last_scroll/page_height

            sign = scroll_momentum/Math.abs(scroll_momentum)
            last_sign = sign


            closest_below = parseInt(last_scroll/page_height)


            scroll_momentum += distance_to_target * .08

            if last_below? and last_below != closest_below
                scroll_momentum = 0
                scroll_paused = time
            last_below = closest_below

            # Move by the momentum
            scroll_momentum *= .5
            diff = scroll_momentum * browser_height * browser_height * .002
            if parseInt(Math.abs(diff)) > 0
                $(window).scrollTop last_scroll + diff



        if current_page != last_page
            start_time = time
            new_page get_points time, dtim, start_time - time
        set_goals get_points time, dtim, time - start_time
        for d in dots
            d.do_frame Math.min(browser_height, browser_width)
        last_page = current_page
        requestAnimationFrame do_frame
    requestAnimationFrame do_frame