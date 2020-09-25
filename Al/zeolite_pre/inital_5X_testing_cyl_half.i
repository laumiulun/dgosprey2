
[Outputs]
	exodus = true
	csv = true
	print_linear_residuals = false
  file_base = result/x5_n2/x5_initial_2cyl/x5_initial_cyl_half
	perf_graph = true
[] #END Outputs

[GlobalParams]
 length = 25 # cm
 pellet_diameter = 0.045 # cm
 inner_diameter = 7.5 # cm
 # flow_rate =  442251.8# cm3/hr
 flow_rate = 4.42e5
 # dt = 0.000277778 # 1s
 # dt = 1
 dt = 0.01
 sigma = 1   # Penalty value:  NIPG = 0   otherwise, > 0  (between 0.1 and 10) epsilon = 1  #  -1 = SIPG   0 = IIPG   1 = NIPG
 epsilon =  1 #  -1 = SIPG   0 = IIPG   1 = NIPG
[] #END GlobalParams


[Problem]
	# coord_type = RZ
	# coord_type = RZ
[] #END Problem

# -----------------------------------------------------------------------------

[Mesh]
	# type = GeneratedMesh
	# dim = 2
	# nx = 40
	# ny = 100
	# xmin = 0.0
	# xmax = 3.75 #cm
	# ymin = 0.0
	# ymax = 25 #cm
	type = FileMesh
	file = ../geometry/cyl_half.e
	boundary_id = '1 2 3 4'
	boundary_name = 'bottom top one-half curve-half'
[] # END Mesh

# -----------------------------------------------------------------------------
[Variables]
	[./N2]
		order = FIRST
		family = MONOMIAL
	[../]

	[./O2]
		order = FIRST
		family = MONOMIAL
	[../]

	[./column_temp]
		order = FIRST
		family = MONOMIAL
		initial_condition = 298.15
	[../]

	[./N2_Adsorbed]
		order = FIRST
		family = MONOMIAL
		initial_condition = 0.0
	[../]
	[./N2_AdsorbedHeat]
		order = FIRST
		family = MONOMIAL
		initial_condition = 0.0
	[../]
[] #

[AuxVariables]
  [./total_pressure]
    order = FIRST
    family = MONOMIAL
    initial_condition = 101.35 # kPA
  [../]
  [./ambient_temp]
    order = FIRST
    family = MONOMIAL
    initial_condition = 298.15
  [../]
  [./wall_temp]
    order = FIRST
    family = MONOMIAL
    initial_condition = 298.15
  [../]
[]

# -----------------------------------------------------------------------------
[Kernels]
  # ----------------------
  # N2 Bed Mass
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
  # ----------------------
  # O2 Bed Mass
	[./accumO2]
		type = BedMassAccumulation
		variable = O2
	[../]
	[./diffO2]
		type = GColumnMassDispersion
		variable = O2
		index = 1
	[../]
	[./advO2]
		type = GColumnMassAdvection
		variable = O2
	[../]

  # ----------- Mass transfer (only need for components getting absorbed)
	[./N2_MT]
		type = SolidMassTransfer
		variable = N2
		coupled = N2_Adsorbed
	[../]
  # ----------- Heat Transfer Equation  ------------
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

  # ------------- Coupled Variables between heat variable and N2 Absored
	[./N2_columnAdsHeat]
		type = SolidHeatTransfer
		variable = column_temp
		coupled = N2_AdsorbedHeat
	[../]
  # --------- Heat of adsorption between N2 and N2 Absorbed
	[./N2_adsheat]
		type = HeatofAdsorption
		variable = N2_AdsorbedHeat
		coupled = N2_Adsorbed
    index = 0
	[../]
  # Using Langmuir Forcing Functions
	# [./N2_adsorption]
	# 	type = CoupledLangmuirForcingFunction
	# 	variable = N2_Adsorbed
	# 	coupled = N2
	# 	langmuir_coeff = 10000 # L/mol
	# 	max_capacity = 11.67 # mol/kg
	# [../]
  # Switch to using GSTA
  [./N2_Adsorption]
    type = CoupledGSTALDFmodel
    variable = N2_Adsorbed
    coupled_gas = N2
    coupled_temp = column_temp
    index = 0
		alpha = 15
		beta = 15
  [../]
  # [./N2_Adsorption]
  #   type = CoupledGSTALDFmodel
  #   index = 0
  #   alpha = 15
  #   beta = 15
  #   coupled_gas = 'N2'
  #   variable = N2_Adsorbed
  #   coupled_temp = column_temp
  # [../]
  # [./]
[] #END Kernels

# -----------------------------------------------------------------------------
[DGKernels]
  # DG ---------- N2
	[./dg_disp_N2]
		type = DGColumnMassDispersion
		variable = N2
		index = 0
	[../]

	[./dg_adv_N2]
		type = DGColumnMassAdvection
		variable = N2
	[../]
  # DG ---------- O2
	[./dg_disp_O2]
		type = DGColumnMassDispersion
		variable = O2
		index = 1
	[../]
	[./dg_adv_O2]
		type = DGColumnMassAdvection
		variable = O2
	[../]

  # DG ---------- Column Heat
	[./dg_disp_heat]
		type = DGColumnHeatDispersion
		variable = column_temp
	[../]

	[./dg_adv_heat]
		type = DGColumnHeatAdvection
		variable = column_temp
	[../]

[] #END DGKernels

# -----------------------------------------------------------------------------
[AuxKernels]
	[./column_pressure]
		type = TotalColumnPressure
		variable = total_pressure
		temperature = column_temp
		coupled_gases = 'N2 O2'
		execute_on = 'initial timestep_end'
	[../]

	[./wall_temp_calc]
		type = WallTemperature
		variable = wall_temp
		column_temp = column_temp
		ambient_temp = ambient_temp
		execute_on = 'initial timestep_end'
	[../]
[] #END AuxKernels



[ICs]

	[./N2_IC]
		type = ConcentrationIC
		variable = N2
		initial_mole_frac = 0.79
		initial_press = 101.35
		initial_temp = 303.15
	[../]

	[./O2_IC]
		type = ConcentrationIC
		variable = O2
		initial_mole_frac = 0.21
		initial_press = 101.35
		initial_temp = 303.15
	[../]

[] #END

[BCs]

	[./N2_Flux]
		type = DGMassFluxBC
		variable = N2
		boundary = 'top bottom'
		input_temperature = 303.15
		input_pressure = 101.35
		input_molefraction = 0.775 # 78 % N2
		index = 0
	[../]

	[./O2_Flux]
		type = DGMassFluxBC
		variable = O2
		boundary = 'top bottom'
		input_temperature = 303.15
		input_pressure = 101.35
		input_molefraction = 0.21
		index = 1
	[../]


	# [./H2O_Flux]
	# 	type = DGMassFluxBC
	# 	variable = H2O
	# 	boundary = 'top bottom'
	# 	input_temperature = 303.15
	# 	input_pressure = 101.35
	# 	input_molefraction = 0.015
	# 	index = 2
	# [../]

	[./Heat_Gas_Flux]
		type = DGHeatFluxBC
		variable = column_temp
		boundary = 'top bottom'
		input_temperature = 303.15
	[../]

	[./Heat_Wall_Flux]
		type = DGColumnWallHeatFluxLimitedBC
		variable = column_temp
		boundary = 'one-half curve-half'
		wall_temp = wall_temp
	[../]

[] #END BCs


# -----------------------------------------------------------------------------
[Materials]

	[./BedMaterials]
		type = BedProperties
		block = 1
    outer_diameter = 16 # cm
		bulk_porosity = 0.585 # %
		wall_density = 8.0 # g/cm3
		# wall_heat_capacity = 0.5
    wall_heat_capacity =  0.502 # J/g/K
		wall_heat_trans_coef = 6.12 # J/hr/cm2/K
		extern_heat_trans_coef = 6.12 # J/hr/cm2/K
	[../]

	[./FlowMaterials]
		type = GasFlowProperties
		block = 1
    # N2 and O2
		molecular_weight = '28.016 32'
		comp_heat_capacity = '1.04 0.919 '
		comp_ref_viscosity = '0.0001781 0.0002018'
		comp_ref_temp = '300.55 292.25'
		comp_Sutherland_const = '111 127'
		temperature = column_temp
		total_pressure = total_pressure

		coupled_gases = 'N2 O2'
	[../]
  # X5
  [./AdsorbentMaterials]
		type = AdsorbentProperties
		block = 1
		binder_fraction = 0.175
		binder_porosity = 0.27
		crystal_radius = 1.5
		macropore_radius = 3.5e-6
		pellet_density = 1.69
		pellet_heat_capacity = 1.045
		ref_diffusion = '0 0'
		activation_energy = '0 0'
		ref_temperature = '0 0'
		affinity = '0 0'
		temperature = column_temp
		coupled_gases = 'N2 O2'
	[../]

	[./AdsorbateMaterials]
		type = ThermodynamicProperties
		block = 1
		temperature = column_temp
		total_pressure = total_pressure
		coupled_gases = 'N2 O2'
		number_sites = '1 0'
		maximum_capacity = '15.0 0' #mol/kg 11.67
		molar_volume = '22.4 0' #mol/cm3
    #
		enthalpy_site_1 = '-11321 0'
		enthalpy_site_2 = '0 0'
		enthalpy_site_3 = '0 0'
		enthalpy_site_4 = '0 0'
		enthalpy_site_5 = '0 0 '
		enthalpy_site_6 = '0 0'

		entropy_site_1 = '-25.77 0'
		entropy_site_2 = '0 0'
		entropy_site_3 = '0 0'
		entropy_site_4 = '0 0'
		entropy_site_5 = '0 0'
		entropy_site_6 = '0 0'
	[../]
[] #END Materials


[Postprocessors]
	[./dt]
		type = TimestepSize
	[../]
	[./N2_enter]
		type = SideAverageValue
		boundary = 'bottom'
		variable = N2
		execute_on = 'initial timestep_end'
	[../]

	[./N2_avg_gas]
		type = ElementAverageValue
		variable = N2
		execute_on = 'initial timestep_end'
	[../]

	[./N2_exit]
		type = SideAverageValue
		boundary = 'top'
		variable = N2
		execute_on = 'initial timestep_end'
	[../]

  [./O2_enter]
		type = SideAverageValue
		boundary = 'bottom'
		variable = O2
		execute_on = 'initial timestep_end'
	[../]

	[./O2_avg_gas]
		type = ElementAverageValue
		variable = O2
		execute_on = 'initial timestep_end'
	[../]

	[./O2_exit]
		type = SideAverageValue
		boundary = 'top'
		variable = O2
		execute_on = 'initial timestep_end'
	[../]


	[./temp_exit]
		type = SideAverageValue
		boundary = 'top'
		variable = column_temp
		execute_on = 'initial timestep_end'
	[../]

	[./press_exit]
		type = SideAverageValue
		boundary = 'top'
		variable = total_pressure
		execute_on = 'initial timestep_end'
	[../]

	# [./wall_temp]
	# 	type = SideAverageValue
	# 	boundary = 'right'
	# 	variable = wall_temp
	# 	execute_on = 'initial timestep_end'
	# [../]

	[./N2_solid]
		type = ElementAverageValue
		variable = N2_Adsorbed
		execute_on = 'initial timestep_end'
	[../]
[] #END Postprocessors



[Executioner]

	type = Transient
	scheme = bdf2
  # solve_type = PJFNK
	# NOTE: The default tolerances are far to strict and cause the program to crawl
	nl_rel_tol = 1e-10
	nl_abs_tol = 1e-4
	l_tol = 1e-8
	l_max_its = 100
	nl_max_its = 50

	solve_type = pjfnk
	line_search = bt   # Options: default none l2 bt
  # line_search =
	start_time = 0.0
	end_time = 100
	# dtmax = 1 # h
	# dt_max = 0.1
	dtmax = 0.1
	dtmin = 1e-5
	[./TimeStepper]
		# type =
		# type = Solu/tionTimeAdaptiveDT
		type = DGOSPREY_TimeStepper

		# optimal_iterations = 7
		# cutback_factor_at_failure = 0.85
		# growth_factor = 1.2
		# cutback_factor = 0.8
		# dt_max
		# dt = 0.1

	[../]

[] #END Executioner

[Preconditioning]
  active = 'smp'
  [./none]
    type = SMP
    petsc_options = '-snes_converged_reason'
    petsc_options_iname = '-pc_type -ksp_gmres_restart'
    petsc_options_value = 'lu 2000'
  [../]
  [./smp]
		type = SMP
		full = true
		petsc_options = '-snes_converged_reason'
		petsc_options_iname = '-pc_type -ksp_gmres_restart  -snes_max_funcs'
		petsc_options_value = 'lu 2000 20000'
	[../]
  [./fdp]
		type = FDP
		full = true
		petsc_options = '-snes_converged_reason'
		petsc_options_iname = '-mat_fd_coloring_err -mat_fd_type'
		petsc_options_value = '1e-6 ds'
	[../]
[] #END Preconditioning
