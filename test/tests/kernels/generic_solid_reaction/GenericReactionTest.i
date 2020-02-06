[GlobalParams]

    length = 0.1
    pellet_diameter = 0.18
    inner_diameter = 2.5
    flow_rate = 30000
    dt = 0.1    #NOTE: sometimes you need to increase dt for convergence
    sigma = 1   # Penalty value:  NIPG = 0   otherwise, > 0  (between 0.1 and 10)
    epsilon = 1  #  -1 = SIPG   0 = IIPG   1 = NIPG

[] #END GlobalParams

[Problem]

    coord_type = RZ

[] #END Problem

[Mesh]

    type = GeneratedMesh
    dim = 2
    nx = 4
    ny = 4
    xmin = 0.0
    xmax = 1.25 #cm
    ymin = 0.0
    ymax = 0.1 #cm

[] # END Mesh

[Variables]

    [./N2]
        order = FIRST
        family = MONOMIAL
    [../]

    [./column_temp]
        order = FIRST
        family = MONOMIAL
        initial_condition = 423.15
    [../]

    [./Ag_MOR]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.0
    [../]
 
    [./H_MOR]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1.0
    [../]
 
    [./Ag_NO3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 1.0
    [../]

    [./HNO3]
        order = FIRST
        family = MONOMIAL
        initial_condition = 0.0
    [../]
 

[] #END Variables

[AuxVariables]

    [./total_pressure]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 101.35
    [../]

    [./ambient_temp]
        order = CONSTANT
        family = MONOMIAL
        initial_condition = 423.15
    [../]

[] #END AuxVariables

[ICs]

    [./N2_IC]
        type = ConcentrationIC
        variable = N2
        initial_mole_frac = 1.0
        initial_press = 101.35
        initial_temp = 423.15
    [../]

[] #END ICs

[Kernels]

    [./accumN2]
        type = BedMassAccumulation
        variable = N2
    [../]

    [./diffN2]
        type = GColumnMassDispersion
        variable = N2
        index = 0
    [../]

    [./advN2]
        type = GColumnMassAdvection
        variable = N2
    [../]
 
    [./columnAccum]
        type = BedHeatAccumulation
        variable = column_temp
    [../]

    [./columnConduction]
        type = GColumnHeatDispersion
        variable =column_temp
    [../]

    [./columnAdvection]
        type = GColumnHeatAdvection
        variable =column_temp
    [../]
 
    [./H_MOR_MT]
        type = CoefTimeDerivative
        variable = H_MOR
    [../]
 
    [./Ag_MOR_MT]
        type = CoefTimeDerivative
        variable = Ag_MOR
    [../]
 
    [./HNO3_MT]
        type = CoefTimeDerivative
        variable = HNO3
    [../]
 
    [./AgNO3_MT]
        type = CoefTimeDerivative
        variable = Ag_NO3
    [../]
 
    [./Ag_NO3_to_Ag_MOR_1]
        type = VariableOrderReac
        variable = Ag_MOR
        main_variable = Ag_MOR
        coupled_species = 'H_MOR Ag_NO3 HNO3'
        stoichiometry = '-1 -1 1'
        order = '1 1 1'
        main_stoichiometry = 1
        main_order = 1
        forward_rate = 10.0
        reverse_rate = 0.0
    [../]
 
    [./Ag_NO3_to_Ag_MOR_2]
        type = VariableOrderReac
        variable = HNO3
        main_variable = HNO3
        coupled_species = 'H_MOR Ag_NO3 Ag_MOR'
        stoichiometry = '-1 -1 1'
        order = '1 1 1'
        main_stoichiometry = 1
        main_order = 1
        forward_rate = 10.0
        reverse_rate = 0.0
    [../]
 
    [./Ag_NO3_to_Ag_MOR_3]
        type = VariableOrderReac
        variable = Ag_NO3
        main_variable = Ag_NO3
        coupled_species = 'H_MOR Ag_MOR HNO3'
        stoichiometry = '1 -1 -1'
        order = '1 1 1'
        main_stoichiometry = 1
        main_order = 1
        forward_rate = 0.0
        reverse_rate = 10.0
    [../]
 
    [./Ag_NO3_to_Ag_MOR_4]
        type = VariableOrderReac
        variable = H_MOR
        main_variable = H_MOR
        coupled_species = 'Ag_NO3 Ag_MOR HNO3'
        stoichiometry = '1 -1 -1'
        order = '1 1 1'
        main_stoichiometry = 1
        main_order = 1
        forward_rate = 0.0
        reverse_rate = 10.0
 [../]
 
 
[] #END Kernels

[DGKernels]

    [./dg_disp_N2]
        type = DGColumnMassDispersion
        variable = N2
        index = 0
    [../]

    [./dg_adv_N2]
        type = DGColumnMassAdvection
        variable = N2
    [../]

    [./dg_disp_heat]
        type = DGColumnHeatDispersion
        variable = column_temp
    [../]

    [./dg_adv_heat]
        type = DGColumnHeatAdvection
        variable = column_temp
    [../]

[] #END DGKernels

[AuxKernels]

    [./column_pressure]
        type = TotalColumnPressure
        variable = total_pressure
        temperature = column_temp
        coupled_gases = 'N2'
        execute_on = 'initial timestep_end'
    [../]

[] #END AuxKernels

[BCs]

    [./N2_Flux]
        type = DGMassFluxBC
        variable = N2
        boundary = 'top bottom'
        input_temperature = 423.15
        input_pressure = 101.35
        input_molefraction = 1.0
        index = 0
    [../]

[] #END BCs

[Materials]

    [./BedMaterials]
        type = BedProperties
        block = 0
        outer_diameter = 2.8
        bulk_porosity = 0.3336
        wall_density = 8.0
        wall_heat_capacity = 0.5
        wall_heat_trans_coef = 6.12
        extern_heat_trans_coef = 6.12
    [../]

    [./FlowMaterials]
        type = GasFlowProperties
        block = 0
        molecular_weight = '28.016'
        comp_heat_capacity = '1.04'
        comp_ref_viscosity = '0.0001781'
        comp_ref_temp = '300.55'
        comp_Sutherland_const = '111'
        temperature = column_temp
        total_pressure = total_pressure
        coupled_gases = 'N2'
    [../]

    [./AdsorbentMaterials]
        type = AdsorbentProperties
        block = 0
        binder_fraction = 0.0
        binder_porosity = 0.384
        crystal_radius = 0.0
        macropore_radius = 2.65e-6
        pellet_density = 3.057
        pellet_heat_capacity = 1.2
        ref_diffusion = '0'
        activation_energy = '0'
        ref_temperature = '0'
        affinity = '0'
        temperature = column_temp
        coupled_gases = 'N2'
    [../]

    [./AdsorbateMaterials]
        type = ThermodynamicProperties
        block = 0
        temperature = column_temp
        total_pressure = total_pressure
        coupled_gases = 'N2'
        number_sites = '0'
        maximum_capacity = '0' #mol/kg
        molar_volume = '0' #cm^3/mol
        enthalpy_site_1 = '0'
        enthalpy_site_2 = '0'
        enthalpy_site_3 = '0'
        enthalpy_site_4 = '0'
        enthalpy_site_5 = '0'
        enthalpy_site_6 = '0'

        entropy_site_1 = '0'
        entropy_site_2 = '0'
        entropy_site_3 = '0'
        entropy_site_4 = '0'
        entropy_site_5 = '0'
        entropy_site_6 = '0'
    [../]

[] #END Materials

[Postprocessors]

    [./press_exit]
        type = SideAverageValue
        boundary = 'top'
        variable = total_pressure
        execute_on = 'initial timestep_end'
    [../]

    [./Ag_NO3_Sol]
        type = ElementAverageValue
        variable = Ag_NO3
        execute_on = 'initial timestep_end'
    [../]

    [./Ag_MOR_Sol]
        type = ElementAverageValue
        variable = Ag_MOR
        execute_on = 'initial timestep_end'
    [../]
 
    [./H_MOR_Sol]
        type = ElementAverageValue
        variable = H_MOR
        execute_on = 'initial timestep_end'
    [../]
 
    [./HNO3_Liq]
        type = ElementAverageValue
        variable = HNO3
        execute_on = 'initial timestep_end'
    [../]

[] #END Postprocessors

[Executioner]

    type = Transient
    scheme = bdf2

# NOTE: The default tolerances are far to strict and cause the program to crawl
    nl_rel_tol = 1e-10
    nl_abs_tol = 1e-4
    l_tol = 1e-8
    l_max_its = 200
    nl_max_its = 80

    solve_type = pjfnk
    line_search = bt    # Options: default none l2 bt basic
    start_time = 0.0
    end_time = 1.0
    dtmax = 0.1

    [./TimeStepper]
        type = ConstantDT
    [../]

[] #END Executioner

[Preconditioning]

    [./smp]
        type = SMP
        full = true
        petsc_options = '-snes_converged_reason'
        petsc_options_iname = '-pc_type -sub_pc_type -pc_hypre_type -ksp_gmres_restart  -snes_max_funcs'
        petsc_options_value = 'lu ilu boomeramg 2000 20000'
    [../]

[] #END Preconditioning

[Outputs]

    exodus = true
    csv = true
    print_linear_residuals = false

[] #END Outputs

