getmass(p::AbstractPoint, ::Nothing) = 0.0
getmass(p::AbstractPoint, u::Units) = 0.0 * u
getpos(p::AbstractPoint) = p
getvel(p::AbstractPoint, ::Nothing) = zero(p)
getvel(p::AbstractPoint, u::Units) = zero(p) * (one(p.x) * u)

getmass(p::AbstractParticle, ::Nothing) = p.Mass
getmass(p::AbstractParticle, u::Units) = uconvert(u, p.Mass)
getpos(p::AbstractParticle) = p.Pos
getvel(p::AbstractParticle, ::Nothing) = p.Vel
getvel(p::AbstractParticle, u::Units) = uconvert(u, p.Vel)

function update_treenodes_kernel(tree::AbstractTree, no::Int64, sib::Int64, father::Int64)
    MaxData = tree.config.MaxData
    MaxTreenode = tree.config.MaxTreenode
    treenodes = tree.treenodes
    NextNodes = tree.NextNodes
    ExtNodes = tree.ExtNodes

    uLength = getuLength(tree.units)
    uTime = getuTime(tree.units)
    uMass = getuMass(tree.units)

    mass = nothing
    s = nothing
    vs = nothing
    hmax = nothing

    if no > MaxData && no <= MaxData + MaxTreenode  # internal node
        suns = deepcopy(treenodes[no - MaxData].DaughterID)

        if tree.last > 0
            if tree.last > MaxData
                if tree.last > MaxData + MaxTreenode  # pseudo-particle
                    NextNodes[tree.last - MaxTreenode] = no
                else
                    treenodes[tree.last - MaxData].NextNode = no
                end
            else
                NextNodes[tree.last] = no
            end
        end
        tree.last = no

        if isnothing(tree.units)
            mass = 0.0
            s = PVector()
            vs = PVector()
            hmax = 0.0
        else
            mass = 0.0 * uMass
            s = PVector(uLength)
            vs = PVector(uLength / uTime)
            hmax = 0.0 * uLength
        end

        for j in 1:8
            p = suns[j]
            if p > 0
                # check if we have a sibling on the same level
                jj = 0
                pp = 0
                for jj = (j+1) : 8
                    pp = suns[jj]
                    if pp > 0
                        break
                    end
                end

                if jj <= 8  # Have sibling
                    nextsib = pp
                else
                    nextsib = sib
                end

                # Depth-First
                update_treenodes_kernel(tree, p, nextsib, no)

                if p > MaxData
                    if p <= MaxData + MaxTreenode
                        mass += treenodes[p - MaxData].Mass
                        s += ustrip(uMass, treenodes[p - MaxData].Mass) * treenodes[p - MaxData].MassCenter
                        vs += ustrip(uMass, treenodes[p - MaxData].Mass) * ExtNodes[p - MaxData].vs

                        hmax = max(hmax, ExtNodes[p - MaxData].hmax)
                    else # Pseudo-particle
                        # Nothing to do since we had not updated pseudo data
                    end
                else  # A particle
                    pa = tree.data[p]

                    mass += getmass(pa, uMass)
                    s += ustrip(uMass, getmass(pa, uMass)) * getpos(pa)
                    vs += ustrip(uMass, getmass(pa, uMass)) * getvel(pa, uLength / uTime)
                end
            end
        end

        if ustrip(mass) > 0.0
            s /= ustrip(uMass, mass)
            vs /= ustrip(uMass, mass)
        else
            s = treenodes[no - MaxData].Center # Geometric center
        end

        treenodes[no - MaxData].MassCenter = s
        treenodes[no - MaxData].Mass = mass

        treenodes[no - MaxData].BitFlag = 0

        ExtNodes[no - MaxData].vs = vs
        ExtNodes[no - MaxData].hmax = hmax

        treenodes[no - MaxData].Sibling = sib
        treenodes[no - MaxData].Father = father
    else # single particle or pseudo particle
        if tree.last > 0
            if tree.last > MaxData
                if tree.last > MaxData + MaxTreenode
                    NextNodes[tree.last - MaxTreenode] = no
                else
                    treenodes[tree.last - MaxData].NextNode = no
                end
            else
                NextNodes[tree.last] = no
            end
        end

        tree.last = no
        if no <= MaxData
            tree.Fathers[no] = father
        end
    end
end

function finish_last(tree::AbstractTree)
    if tree.last > tree.config.MaxData
        if tree.last > tree.config.MaxData + tree.config.MaxTreenode
            tree.NextNodes[tree.last - tree.config.MaxTreenode] = 0
        else
            tree.treenodes[tree.last - tree.config.MaxData].NextNode = 0
        end
    else
        tree.NextNodes[tree.last] = 0
    end
end

function update_local_data(tree::AbstractTree)
    tree.Fathers = zeros(Int64, tree.config.MaxData)
    tree.ExtNodes = [ExtNode() for i in 1:tree.config.MaxTreenode]
    tree.NextNodes = zeros(Int64, tree.config.MaxData + tree.config.MaxTopnode)

    tree.last = 0
    update_treenodes_kernel(tree, tree.config.MaxData + 1, 0, 0)
    finish_last(tree)
end

function fill_pseudo_buffer(tree::AbstractTree)
    treenodes = tree.treenodes
    DomainMoment = tree.DomainMoment
    MaxData = tree.config.MaxData

    empty!(tree.MomentsToSend)

    for i in tree.DomainMyStart : tree.DomainMyEnd
        no = tree.DomainNodeIndex[i]
        DomainMoment[i].Mass = treenodes[no - MaxData].Mass
        DomainMoment[i].MassCenter = treenodes[no - MaxData].MassCenter
        DomainMoment[i].Vel = tree.ExtNodes[no - MaxData].vs
    end

    tree.MomentsToSend = tree.DomainMoment[tree.DomainMyStart:tree.DomainMyEnd]
end

function update_pseudo_data(tree::AbstractTree)
    empty!(tree.MomentsToSend)

    uLength = getuLength(tree.units)
    uTime = getuTime(tree.units)
    uMass = getuMass(tree.units)

    if isnothing(tree.units)
        sold = PVector()
        snew = PVector()
        vsold = PVector()
        vsnew = PVector()
        massold = 0.0
        massnew = 0.0
    else
        sold = PVector(uLength)
        snew = PVector(uLength)
        vsold = PVector(uLength / uTime)
        vsnew = PVector(uLength / uTime)
        massold = 0.0 * uMass
        massnew = 0.0 * uMass
    end

    MaxData = tree.config.MaxData
    treenodes = tree.treenodes
    NextNodes = tree.NextNodes
    ExtNodes = tree.ExtNodes
    DomainMoment = tree.DomainMoment

    for i in 1:tree.NTopLeaves
        if i < tree.DomainMyStart || i > tree.DomainMyEnd
            no = tree.DomainNodeIndex[i]

            sold = treenodes[no - MaxData].MassCenter
            vsold = ExtNodes[no - MaxData].vs
            massold = treenodes[no - MaxData].Mass

            snew = DomainMoment[i].MassCenter
            vsnew = DomainMoment[i].Vel
            massnew = DomainMoment[i].Mass

            while no > 0
                mm = treenodes[no - MaxData].Mass + massnew - massold
                if ustrip(mm) > 0.0
                    treenodes[no - MaxData].MassCenter = (treenodes[no - MaxData].Mass * treenodes[no - MaxData].MassCenter +
                                                            massnew * snew - massold * sold) / mm
                    ExtNodes[no - MaxData].vs = (treenodes[no - MaxData].Mass * ExtNodes[no - MaxData].vs +
                                                            massnew * vsnew - massold * vsold) / mm
                end
                treenodes[no - MaxData].Mass = mm
                no = treenodes[no - MaxData].Father
            end # while
        end # if
    end # for
end

function flag_local_treenodes(tree::AbstractTree)
    treenodes = tree.treenodes
    MaxData = tree.config.MaxData
    # mark all top-level nodes
    for i in 1:length(tree.DomainNodeIndex)
        no = tree.DomainNodeIndex[i]

        while no > 0
            if (treenodes[no - MaxData].BitFlag & 1) > 0
                break
            end

            treenodes[no - MaxData].BitFlag |= 1

            no = treenodes[no - MaxData].Father
        end
    end

    # mark top-level nodes that contain local particles
    for i in tree.DomainMyStart:tree.DomainMyEnd
        no = tree.DomainNodeIndex[i]

        while no > 0
            if (treenodes[no - MaxData].BitFlag & 2) > 0
                break
            end

            treenodes[no - MaxData].BitFlag |= 2

            no = treenodes[no - MaxData].Father
        end
    end
end

function update(tree::AbstractTree)
    bcast(tree, update_local_data)
    bcast(tree, fill_pseudo_buffer)

    # send pseudo buffer
    tree.DomainMoment = reduce(vcat, gather(tree, :MomentsToSend))
    bcast(tree, :DomainMoment, tree.DomainMoment)

    bcast(tree, update_pseudo_data)
    bcast(tree, flag_local_treenodes)
end