[GlobalParams]

[] #END GlobalParams

[Problem]
 
	coord_type = RZ
 
[] #END Problem

[Mesh]
 
	type = GeneratedMesh
	dim = 2
	nx = 3
	ny = 5
	xmin = 0.0
	xmax = 0.8636 #cm
	ymin = 0.0
	ymax = 22.86 #cm
 
[] # END Mesh

[Variables]

	[./wall_temp]
		order = FIRST
		family = MONOMIAL
		initial_condition = 220.15
	[../]

	[./column_temp]
		order = FIRST
		family = MONOMIAL
		initial_condition = 220.15
	[../]
 
[] #END Variables

[AuxVariables]
 
	[./Kr]
		order = FIRST
		family = MONOMIAL
	[../]
 
	[./Xe]
		order = FIRST
		family = MONOMIAL
	[../]
 
	[./He]
		order = FIRST
		family = MONOMIAL
	[../]

	[./total_pressure]
		order = FIRST
		family = MONOMIAL
		initial_condition = 101.35
	[../]

	[./ambient_temp]
		order = FIRST
		family = MONOMIAL
		initial_condition = 250.15
	[../]
 
	[./Kr_Adsorbed]
		order = FIRST
		family = MONOMIAL
		initial_condition = 0.0
	[../]
 
	[./Xe_Adsorbed]
		order = FIRST
		family = MONOMIAL
		initial_condition = 0.0
	[../]
 
	[./Kr_AdsorbedHeat]
		order = FIRST
		family = MONOMIAL
		initial_condition = 0.0
	[../]
 
	[./Xe_AdsorbedHeat]
		order = FIRST
		family = MONOMIAL
		initial_condition = 0.0
	[../]

[] #END AuxVariables

[ICs]

	[./Kr_IC]
		type = ConcentrationIC
		variable = Kr
		initial_mole_frac = 0.0
		initial_press = 101.35
		initial_temp = 220.15
	[../]

	[./Xe_IC]
		type = ConcentrationIC
		variable = Xe
		initial_mole_frac = 0.0
		initial_press = 101.35
		initial_temp = 220.15
	[../]

	[./He_IC]
		type = ConcentrationIC
		variable = He
		initial_mole_frac = 1.0
		initial_press = 101.35
		initial_temp = 220.15
	[../]

[] #END ICs

[Kernels]

	[./wallAccum]
		type = WallHeatAccumulation
		variable = wall_temp
	[../]
 
	[./wall_bed_trans]
		type = BedWallHeatTransfer
		variable = wall_temp
		coupled = column_temp
	[../]
 
	[./wall_amb_trans]
		type = WallAmbientHeatTransfer
		variable = wall_temp
		coupled = ambient_temp
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

[] #END Kernels

[DGKernels]

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
		execute_on = 'initial timestep_end'
		variable = total_pressure
		temperature = column_temp
		coupled_gases = 'Kr Xe He'
	[../]

[] #END AuxKernels

[BCs]

	[./Heat_Gas_Flux]
		type = DGHeatFluxBC
		variable = column_temp
		boundary = 'top bottom'
		input_temperature = 250.15
	[../]

	[./Heat_Wall_Flux]
		type = DGColumnWallHeatFluxLimitedBC
		variable = column_temp
		boundary = 'right left'
		wall_temp = wall_temp
	[../]

[] #END BCs

[Materials]

	[./BedMaterials]
		type = BedProperties
		block = 0
		length = 22.86
		inner_diameter = 1.7272
		outer_diameter = 1.905
		bulk_porosity = 0.798				#not known
		wall_density = 7.7
		wall_heat_capacity = 0.5
		wall_heat_trans_coef = 9.0
		extern_heat_trans_coef = 90.0       #not known
	[../]

	[./FlowMaterials]
		type = GasFlowProperties
		block = 0
		molecular_weight = '83.8 131.29 4.0026'
		comp_heat_capacity = '0.25 0.16 5.1916'
		comp_ref_viscosity = '0.00023219 0.00021216 0.0001885'
		comp_ref_temp = '273.15 273.15 273.15'
		comp_Sutherland_const = '266.505 232.746 80.0'
		flow_rate = 2994.06
		temperature = column_temp
		total_pressure = total_pressure
		coupled_gases = 'Kr Xe He'
	[../]

	[./AdsorbentMaterials]
		type = AdsorbentProperties
		block = 0
		binder_fraction = 0.175				#not known
		binder_porosity = 0.27				#not known
		crystal_radius = 1.5				#not known
		pellet_diameter = 0.236				#not known
		macropore_radius = 3.5e-6			#not Known
		pellet_density = 1.69				#not Known
		pellet_heat_capacity = 1.045		#not known
		ref_diffusion = '0 0 0'
		activation_energy = '0 0 0'
		ref_temperature = '0 0 0'
		affinity = '0 0 0'
		temperature = column_temp
		coupled_gases = 'Kr Xe He'
	[../]

	[./AdsorbateMaterials]
		type = ThermodynamicProperties
		block = 0
		temperature = column_temp
		total_pressure = total_pressure
		coupled_gases = 'Kr Xe He'
		number_sites = '2 3 0'
		maximum_capacity = '1.716 1.479 0' #mol/kg
		molar_volume = '20.785 25.412 0' #cm^3/mol
 
		enthalpy_site_1 = '-44696.86 -18455.18 0'
		enthalpy_site_2 = '-65465.52 -35511.74 0'
		enthalpy_site_3 = '0 -53315.13 0'
		enthalpy_site_4 = '0 0 0'
		enthalpy_site_5 = '0 0 0'
		enthalpy_site_6 = '0 0 0'

		entropy_site_1 = '-170.45 -23.25 0'
		entropy_site_2 = '-248.55 -62.45 0'
		entropy_site_3 = '0 -100.10 0'
		entropy_site_4 = '0 0 0'
		entropy_site_5 = '0 0 0'
		entropy_site_6 = '0 0 0'
	[../]

[] #END Materials

[Postprocessors]

	[./Kr_exit]
		type = SideAverageValue
		boundary = 'top'
		variable = Kr
		execute_on = 'initial timestep_end'
	[../]

	[./Xe_exit]
		type = SideAverageValue
		boundary = 'top'
		variable = Xe
		execute_on = 'initial timestep_end'
	[../]

	[./He_exit]
		type = SideAverageValue
		boundary = 'top'
		variable = He
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

	[./wall_temp]
		type = SideAverageValue
		boundary = 'right'
		variable = wall_temp
		execute_on = 'initial timestep_end'
	[../]

	[./Kr_solid]
		type = ElementAverageValue
		variable = Kr_Adsorbed
		execute_on = 'initial timestep_end'
	[../]

	[./Kr_heat]
		type = ElementAverageValue
		variable = Kr_AdsorbedHeat
		execute_on = 'initial timestep_end'
	[../]

	[./Xe_solid]
		type = ElementAverageValue
		variable = Xe_Adsorbed
		execute_on = 'initial timestep_end'
	[../]

	[./Xe_heat]
		type = ElementAverageValue
		variable = Xe_AdsorbedHeat
		execute_on = 'initial timestep_end'
	[../]

[] #END Postprocessors

[Executioner]

	type = Transient
	scheme = implicit-euler

	# NOTE: The default tolerances are far to strict and cause the program to crawl
	nl_rel_tol = 1e-6
	nl_abs_tol = 1e-6
	nl_rel_step_tol = 1e-10
	nl_abs_step_tol = 1e-10
	l_tol = 1e-6
	l_max_its = 100
	nl_max_its = 100

	solve_type = jfnk
	line_search = bt    # Options: default shell none basic l2 bt cp
	start_time = 0.0
	end_time = 0.02
	dtmax = 0.1
	petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
	petsc_options_value = 'hypre boomeramg 100'

	[./TimeStepper]
		#Need to write a custom TimeStepper to enforce a maximum allowable dt
		type = ConstantDT
		dt = 0.01
	[../]

[] #END Executioner

[Preconditioning]
	
	[./precond]
		type = PBP
		solve_order = 'column_temp wall_temp'
		preconditioner = 'ILU ILU'
	[../]

[] #END Preconditioning

[Outputs]

	exodus = true
	csv = true
	print_linear_residuals = false

[] #END Outputs
