rollout pipeDreamRollout "Pipe dream"(
	
	spinner widthSpinner "Width" range:[0, 1000000, 20000] type:#worldunits
	spinner heightSpinner "Height" range:[0, 1000000, 40000] type:#worldunits
	spinner numPipesSpinner "Number of pipes" range:[0, 1000, 40] type:#integer
	spinner stepXSpinner "Step X" range:[0, 1000000, 10000] type:#worldunits
	spinner stepYSpinner "Step Y" range:[0, 1000000, 10000] type:#worldunits
	spinner percentStraightSpinner "Straight pipes %"  range:[0,100,40] type:#float
	spinner percentDecorationSpinner "Pipe Decoration %" range:[0,100,30] type:#float
	spinner percentGuideSpinner "Pipe Rail %" range:[0,100,40] type:#float
	spinner percentMultiSpinner "Multi pipe %" range:[0,100,30] type:#float
	spinner percentRoundSpinner "Round Chamfer %" range:[0,100,35] type:#float
	progressbar progress 
	button doItButton "Generate"
	
	fn getDecoration r profileNum type = (
		local h = random 100 400
		local w = (2*(r+ random 20 60))
		local w2 = r/(profileNum as float)
		local decoration
		if type == "cylinder" then (
			local rad  = (r+ random 20 60) 
			decoration = Cylinder name:"Decoration" radius:rad height:h pos:[0,0,0]
			convertToMesh decoration
			local num = random 0 3
			local oldH = h
			if num > 0 then (
				rad = (rad + random 15 30)
				h = (h/(random (num+0.2) 5.0))
				local tmp = Cylinder radius:rad height:h pos:[0,0,0]
				for i=1 to num-1 do (
					attach decoration (copy tmp pos:[0,0,i*oldH/(num-1)])
				)
				attach decoration tmp
			)
			local boltR = (random 20.0 40.0)
			if boltR > h*0.5 then boltR = h*0.5
			local boltH = (2*rad + random 10.0 15.0)
			local boltNum = random 3 7
			local bolt = Cylinder radius:boltR height:boltH pos:[0,0,0]
			rotate bolt (eulerangles 0 90 0 )
			local d = boltH*0.5
			local c = copy bolt
			bolt.pos = [-d,0,0]
			convertToMesh bolt
			for i=1 to boltNum-1 do (
				local t = copy c
				local a = (i*180.0/(boltNum as float))
				rotate t (eulerangles 0 0 a )
				t.pos = [-d*cos(a),-d*sin(a),0]
				attach bolt t
			)
			for i=1 to num-1 do (
				local t = copy bolt
				t.pos = [t.pos[1],0, h*0.5 + i*oldH/(num-1)]
				attach decoration t
			)
			bolt.pos = [bolt.pos[1], 0, h*0.5]
			attach decoration bolt
			delete c
			decoration.objectoffsetpos = [0, 0, -h*0.5]
		) else if type == "box" then (
			decoration = Chamferbox name:"Decoration" width:w length:(2*w2+ random 20 60) height:h pos:[0,0,0] Fillet:(random 8 12) Fillet_Segments:1 smooth:0
			decoration.objectoffsetpos = [0, 0, -h*0.5]
		)
		decoration.wirecolor = color 120 120 120
		return decoration
	)
	
	fn placeObject spline obj l = (
		local p = lengthInterp spline 1 l
		obj.pos = p
		local t = lengthTangent spline 1 l
		local a = atan2 t[1] t[3]
		rotate obj (eulerangles 0 a 0 )
	)
	
	fn chamferKnot spline width pos dir1 dir2 s1 s2 round= (
		local p = [pos[1],pos[2],pos[3]]
		p[dir1] = p[dir1] - s1*width
		if round then(
			local t = [0,0,0]
			t[dir1] = -s1*width*0.75
			addknot spline 1 #bezier #curve p (p + t) (p - t)
		) else (
			addknot spline 1 #corner #line p
		)
		p = pos
		p[dir2] += s2*width
		if round then(
			local t = [0,0,0]
			t[dir2] = -s2*width*0.75
			addknot spline 1 #bezier #curve p (p + t) (p - t)
		) else (
			addknot spline 1 #corner #line p
		)
	)
	fn doIt = (
		escapeEnable

		local numS = numPipesSpinner.value
		local height = heightSpinner.value
		local width = widthSpinner.value
		local maxLength = [stepXSpinner.value, stepYSpinner.value,0]
		local percentStraight = percentStraightSpinner.value
		local percentDecoration = percentDecorationSpinner.value
		local percentGuide = percentGuideSpinner.value
		local percentMulti = percentMultiSpinner.value
		local percentRound = percentRoundSpinner.value
		while $Line != undefined do (
			delete $Line
		)
		while $Profile!= undefined do (
			delete $Profile
		)
		while $Decoration != undefined do (
			delete $Decoration
		)
		local z = 0
		local layerW = 0
		local oldR = 0
		for i = 1 to numS do (
			progress.value = 100.0*(i as float)/(numS as float)
			local obj = SplineShape name:"Line" pos:[0,0,0]
			addNewSpline obj
			local p = [0,0,0]
			addKnot obj 1 #corner #line p
			local numK = floor(random 1 4)
			local dir = 1
			local minx = 0
			local maxx = 0
			local firstKnot = true
			local straight = (random 1 100) < percentStraight
			local offset = 0
			local round = (random 1 100) < percentRound
			if straight then (
				offset = random 100 1000
			)
			local chamferRadius = random 100 600
			if round then (
				chamferRadius = random 400 1000
			)
			while p[2] < height-chamferRadius do (
				if straight then (
					local dir2 = 2
					local l = height
					local sOld = 1
					local s = 1
				)
				else (
					local sign = 1 - 2*floor(random 0 1)
					local dir2 = 1+ mod (dir) 2
					local l = random (chamferRadius*3) maxLength[dir2]
					local sOld = s
					local s = case dir2 of(
						1: sign
						2: 1
					)
				)
				local pOld = [p[1],p[2],p[3]]
				p[dir2] = p[dir2] + l*s
				if p[1] < minx then (
					minx = p[1]
				)
				if p[1] > maxx then (
					maxx = p[1]
				)
				if p[2] > height-chamferRadius then (
					p[2] = height
				)
				if not firstKnot then (
					chamferKnot obj chamferRadius pOld dir dir2 sOld s round
				)
				firstKnot = false
				dir = dir2
			)
			local w = maxx-minx + offset
			addKnot obj 1 #corner #line p
			if(w) > width then(
				delete obj
			) else (
				local multi = (random 0 100) < percentMulti
				--multi = true
				local maxr = 350
				if chamferRadius*1.5 < maxr then(
					maxr = chamferRadius*1.5
				)
				local r = random 100 maxr
				if r > oldR then (
					oldR = r
				)
				obj.objectoffsetpos = [-minx,0,0]
				local posX = layerW
				layerW += w + r*2
				if  layerW >= width  then (
					z += r + oldR
					layerW = w  + r*2
					posX = 0
					oldR = r
				)
				obj.pos = [posX+r,z,0]
				obj.wirecolor = color 120 120 120
				rotate obj (eulerangles 90 0 0 )
				local guide = (random 0 100) < percentGuide
				local profileNum = 1
				if multi then (
					profileNum = random 2 3
					guide = false
				)
				if (random 1 100) < percentDecoration then (
					local decorationStep = (random 1500 3000) / curveLength obj
					local decoration 
					if profileNum > 1 then (
						decoration = getDecoration r profileNum "box"
					) else (
						decoration = getDecoration r profileNum "cylinder"
					)
					local accum = 0
					while accum < 1 do (
						local inst = instance decoration name:"Decoration"
						inst.wirecolor = color 120 120 120
						placeObject obj inst accum
						accum  += decorationStep
					)
					delete decoration
				)
				local s = sweep()
				r = r/(profileNum as float)
				local profile = splineshape pos:[0,0,0] name:"Profile"
				addAndWeld profile (convertToSplineShape (Circle radius:r pos:[-r*(profileNum-1),0,0])) 0.0
				if guide then (
					local num = random 3 8
					for i=1 to num do(
						local a = i*360/num
						local tmp = (Rectangle width:(random 25.0 50.0) length:(random 30.0 80.0) pos:[cos(a)*r,sin(a)*r,0] Corner_Radius:(random 5.0 10.0) )
						rotate tmp (eulerangles 0 0 a )
						addAndWeld profile (convertToSplineShape tmp) 0.0
					)
				)
				for i = 1 to profileNum-1 do (
					addAndWeld profile (convertToSplineShape (Circle radius:r pos:[r*2*i-r*(profileNum-1),0,0])) 0.0
				)
				s.shapes[1] = profile
				s.customShape = 1
				addModifier obj s
				delete profile
			)
		)
	)
	on doItButton pressed do (
		doit()
		progress.value = 0
	)
)
createdialog pipeDreamRollout width:250