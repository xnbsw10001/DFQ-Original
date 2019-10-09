-- The function is used to create Particle System object for Particle File Data, You can use it in your project.
-- And you need to provide the parameter of texture and lifeTime.

return function (data, texture)
	local ps = love.graphics.newParticleSystem (texture, data.bufferSize)
	
	ps:setEmitterLifetime (data.emitterLifetime)
	ps:setEmissionRate (data.emissionRate)
	ps:setParticleLifetime (unpack (data.particleLifetime))
	ps:setAreaSpread (data.areaSpread.distribution, unpack (data.areaSpread.distance))
	ps:setInsertMode (data.insertMode)
	ps:setOffset (unpack (data.offset))
	ps:setDirection (data.direction)
	ps:setSpread (data.spread)
	ps:setSpeed (unpack (data.speed))
	ps:setParticleLifetime (unpack (data.particleLifetime))
	ps:setRadialAcceleration (unpack (data.radialAcceleration))
	ps:setTangentialAcceleration (unpack (data.tangentialAcceleration))
	ps:setLinearDamping (unpack (data.linearDamping))
	ps:setLinearAcceleration (data.linearAcceleration.min [1], data.linearAcceleration.min [2], data.linearAcceleration.max [1], data.linearAcceleration.max [2])
	ps:setSpin (unpack (data.spin.interval))
	ps:setSpinVariation (data.spin.variation)
	ps:setRotation (unpack (data.rotation.interval))
	ps:setRelativeRotation (data.rotation.enable)
	
	if (#data.colors > 0) then
		ps:setColors (unpack (data.colors))
	end
	
	if (#data.sizes > 0) then
		ps:setSizes (unpack (data.sizes))
	end

    if (data.quad) then
        ps:setQuads (data.quad)
	elseif (#data.quads > 0) then
		local quads = {}
		
		for n=1, #data.quads do
			quads [n] = love.graphics.newQuad (unpack (data.quads [n]))
		end
		
		ps:setQuads (unpack (quads))
		
		return ps, quads
	end
	
	return ps
end