import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart' as config;
import '../../utils/app_strings.dart';
import '../home/home_screen.dart';
import '../home/driver_home_screen.dart';

class RegisterScreen extends StatefulWidget {
	final bool isDriver;
	const RegisterScreen({super.key, this.isDriver = false});

	@override
	State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
	final _formKey = GlobalKey<FormState>();
	final _nameController = TextEditingController();
	final _emailController = TextEditingController();
	final _phoneController = TextEditingController();
	final _passwordController = TextEditingController();
	final _confirmPasswordController = TextEditingController();

	// Driver-specific fields
	final _licenseController = TextEditingController();
	final _vehicleMakeController = TextEditingController();
	final _vehicleModelController = TextEditingController();
	final _vehicleYearController = TextEditingController();

	bool _obscurePassword = true;
	bool _obscureConfirmPassword = true;
	bool _isLoading = false;
	bool _acceptTerms = false;

	@override
	void dispose() {
		_nameController.dispose();
		_emailController.dispose();
		_phoneController.dispose();
		_passwordController.dispose();
		_confirmPasswordController.dispose();
		_licenseController.dispose();
		_vehicleMakeController.dispose();
		_vehicleModelController.dispose();
		_vehicleYearController.dispose();
		super.dispose();
	}

	Future<void> _register() async {
		if (!_formKey.currentState!.validate()) {
			return;
		}

		if (!_acceptTerms) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('You must accept the terms and conditions'),
					backgroundColor: Colors.red,
				),
			);
			return;
		}

		setState(() {
			_isLoading = true;
		});

		try {
			if (widget.isDriver) {
			await AuthService.registerDriver(
					name: _nameController.text.trim(),
					email: _emailController.text.trim(),
					phone: _phoneController.text.trim(),
					password: _passwordController.text,
					licenseNumber: _licenseController.text.trim(),
					vehicleMake: _vehicleMakeController.text.trim(),
					vehicleModel: _vehicleModelController.text.trim(),
					vehicleYear:
							int.tryParse(_vehicleYearController.text.trim()) ??
							DateTime.now().year,
				);

				if (mounted) {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Text(AppConstants.registrationSuccessful),
							backgroundColor: Colors.green,
						),
					);
					Navigator.of(context).pushReplacement(
						MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
					);
				}
			} else {
			await AuthService.register(
					name: _nameController.text.trim(),
					email: _emailController.text.trim(),
					phone: _phoneController.text.trim(),
					password: _passwordController.text,
				);

				if (mounted) {
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Text(AppConstants.registrationSuccessful),
							backgroundColor: Colors.green,
						),
					);
					Navigator.of(context).pushReplacement(
						MaterialPageRoute(builder: (context) => const HomeScreen()),
					);
				}
			}
		} catch (e) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text('${AppConstants.errorOccurred}: ${e.toString()}'),
						backgroundColor: Colors.red,
					),
				);
			}
		} finally {
			if (mounted) {
				setState(() {
					_isLoading = false;
				});
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Container(
				decoration: const BoxDecoration(
					gradient: LinearGradient(
						colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
					),
				),
				child: SafeArea(
					child: LayoutBuilder(
						builder: (context, constraints) {
							final bool isWide = constraints.maxWidth >= 900;
							final EdgeInsets pagePadding = EdgeInsets.symmetric(
								horizontal: isWide ? 48 : AppConstants.defaultPadding,
								vertical: isWide ? 48 : AppConstants.defaultPadding,
							);
							final double maxContentWidth = math.max(
								360,
								math.min(
									720,
									constraints.maxWidth - pagePadding.horizontal,
								),
							);

							return SingleChildScrollView(
								padding: pagePadding,
								child: Align(
									alignment: Alignment.topCenter,
									child: ConstrainedBox(
										constraints: BoxConstraints(maxWidth: maxContentWidth),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												const SizedBox(height: 20),

												// Boton de retroceso
												IconButton(
													onPressed: () => Navigator.pop(context),
													icon: const Icon(
														Icons.arrow_back_ios,
														color: Color(0xFFFFD700),
													),
												),

												const SizedBox(height: 20),

												// Logo y titulo
												Center(
													child: Column(
														children: [
															Container(
																width: 120,
																height: 120,
																decoration: BoxDecoration(
																	color:
																			const Color(0xFFFFD700).withOpacity(0.2),
																	shape: BoxShape.circle,
																	border: Border.all(
																		color: const Color(0xFFFFD700),
																		width: 2,
																	),
																),
																child: const Icon(
																	FontAwesomeIcons.crown,
																	size: 50,
																	color: Color(0xFFFFD700),
																),
															),
															const SizedBox(height: 24),
															Text(
																widget.isDriver
																		? AppConstants.becomeDriver
																		: AppConstants.joinVaneLux,
																textAlign: TextAlign.center,
																style: TextStyle(
																	fontSize: isWide ? 28 : 32,
																	fontWeight: FontWeight.bold,
																	color: Colors.white,
																),
															),
															const SizedBox(height: 8),
															Text(
																widget.isDriver
																		? AppConstants.earnWithLuxury
																		: AppConstants.createAccountEnjoyLuxury,
																textAlign: TextAlign.center,
																style: TextStyle(
																	fontSize: 16,
																	color: Colors.white.withOpacity(0.8),
																),
															),
														],
													),
												),

												const SizedBox(height: 32),

												// Formulario de registro
												Form(
													key: _formKey,
													child: Column(
														children: [
															// Campo Nombre
															Container(
																decoration: BoxDecoration(
																	borderRadius: BorderRadius.circular(15.0),
																	boxShadow: [
																		BoxShadow(
																			color: Colors.black.withOpacity(0.3),
																			blurRadius: 15,
																			offset: const Offset(0, 8),
																		),
																	],
																),
																child: TextFormField(
																	controller: _nameController,
																	decoration: const InputDecoration(
																		hintText: AppConstants.fullName,
																		prefixIcon: Icon(
																			Icons.person_outline,
																			color: Color(0xFF1A1A2E),
																		),
																	),
																	validator: (value) {
																		if (value == null || value.trim().isEmpty) {
																			return AppConstants.pleaseEnterName;
																		}
																		if (!value.trim().isValidName) {
																			return AppConstants.invalidName;
																		}
																		return null;
																	},
																),
															),

															const SizedBox(height: 20),

															// Campo Email
															Container(
																decoration: BoxDecoration(
																	borderRadius: BorderRadius.circular(15.0),
																	boxShadow: [
																		BoxShadow(
																			color: Colors.black.withOpacity(0.3),
																			blurRadius: 15,
																			offset: const Offset(0, 8),
																		),
																	],
																),
																child: TextFormField(
																	controller: _emailController,
																	keyboardType: TextInputType.emailAddress,
																	decoration: const InputDecoration(
																		hintText: AppConstants.email,
																		prefixIcon: Icon(
																			Icons.email_outlined,
																			color: Color(0xFF1A1A2E),
																		),
																	),
																	validator: (value) {
																		if (value == null || value.trim().isEmpty) {
																			return AppConstants.pleaseEnterEmail;
																		}
																		if (!value.trim().isValidEmail) {
																			return AppConstants.invalidEmail;
																		}
																		return null;
																	},
																),
															),

															const SizedBox(height: 20),

															// Campo Telefono
															Container(
																decoration: BoxDecoration(
																	borderRadius: BorderRadius.circular(15.0),
																	boxShadow: [
																		BoxShadow(
																			color: Colors.black.withOpacity(0.3),
																			blurRadius: 15,
																			offset: const Offset(0, 8),
																		),
																	],
																),
																child: TextFormField(
																	controller: _phoneController,
																	keyboardType: TextInputType.phone,
																	decoration: const InputDecoration(
																		hintText: AppConstants.phoneNumber,
																		prefixIcon: Icon(
																			Icons.phone_outlined,
																			color: Color(0xFF1A1A2E),
																		),
																	),
																	validator: (value) {
																		if (value == null || value.trim().isEmpty) {
																			return AppConstants.pleaseEnterPhone;
																		}
																		if (!value.trim().isValidPhone) {
																			return AppConstants.invalidPhone;
																		}
																		return null;
																	},
																),
															),

															const SizedBox(height: 20),

															// Campo Contrasena
															Container(
																decoration: BoxDecoration(
																	borderRadius: BorderRadius.circular(15.0),
																	boxShadow: [
																		BoxShadow(
																			color: Colors.black.withOpacity(0.3),
																			blurRadius: 15,
																			offset: const Offset(0, 8),
																		),
																	],
																),
																child: TextFormField(
																	controller: _passwordController,
																	obscureText: _obscurePassword,
																	decoration: InputDecoration(
																		hintText: AppConstants.password,
																		prefixIcon: const Icon(
																			Icons.lock_outline,
																			color: Color(0xFF1A1A2E),
																		),
																		suffixIcon: IconButton(
																			onPressed: () {
																				setState(() {
																					_obscurePassword = !_obscurePassword;
																				});
																			},
																			icon: Icon(
																				_obscurePassword
																						? Icons.visibility_off
																						: Icons.visibility,
																				color: const Color(0xFF1A1A2E),
																			),
																		),
																	),
																	validator: (value) {
																		if (value == null || value.isEmpty) {
																			return AppConstants.pleaseEnterPassword;
																		}
																		if (!value.isValidPassword) {
																			return 'Password must be at least ${AppConstants.minPasswordLength} characters long';
																		}
																		return null;
																	},
																),
															),

															const SizedBox(height: 20),

															// Campo Confirmar Contrasena
															Container(
																decoration: BoxDecoration(
																	borderRadius: BorderRadius.circular(15.0),
																	boxShadow: [
																		BoxShadow(
																			color: Colors.black.withOpacity(0.3),
																			blurRadius: 15,
																			offset: const Offset(0, 8),
																		),
																	],
																),
																child: TextFormField(
																	controller: _confirmPasswordController,
																	obscureText: _obscureConfirmPassword,
																	decoration: InputDecoration(
																		hintText: AppConstants.confirmPassword,
																		prefixIcon: const Icon(
																			Icons.lock_outline,
																			color: Color(0xFF1A1A2E),
																		),
																		suffixIcon: IconButton(
																			onPressed: () {
																				setState(() {
																					_obscureConfirmPassword =
																							!_obscureConfirmPassword;
																				});
																			},
																			icon: Icon(
																				_obscureConfirmPassword
																						? Icons.visibility_off
																						: Icons.visibility,
																				color: const Color(0xFF1A1A2E),
																			),
																		),
																	),
																	validator: (value) {
																		if (value == null || value.isEmpty) {
																			return AppConstants.pleaseConfirmPassword;
																		}
																		if (value != _passwordController.text) {
																			return AppConstants.passwordsDoNotMatch;
																		}
																		return null;
																	},
																),
															),

															const SizedBox(height: 24),

															// Checkbox terminos y condiciones
															Row(
																children: [
																	Checkbox(
																		value: _acceptTerms,
																		onChanged: (value) {
																			setState(() {
																				_acceptTerms = value ?? false;
																			});
																		},
																		activeColor: const Color(0xFFFFD700),
																		checkColor: const Color(0xFF1A1A2E),
																	),
																	Expanded(
																		child: RichText(
																			text: TextSpan(
																				style: TextStyle(
																					color: Colors.white.withOpacity(0.8),
																					fontSize: 14,
																				),
																				children: const [
																					TextSpan(text: 'Acepto los '),
																					TextSpan(
																						text: 'Terminos y Condiciones',
																						style: TextStyle(
																							color: Color(0xFFFFD700),
																							decoration:
																									TextDecoration.underline,
																						),
																					),
																					TextSpan(text: ' y la '),
																					TextSpan(
																						text: 'Politica de Privacidad',
																						style: TextStyle(
																							color: Color(0xFFFFD700),
																							decoration:
																									TextDecoration.underline,
																						),
																					),
																				],
																			),
																		),
																	),
																],
															),

															const SizedBox(height: 30),

															// Boton de registro
															Container(
																width: double.infinity,
																height: 60,
																decoration: BoxDecoration(
																	borderRadius: BorderRadius.circular(15.0),
																	gradient: const LinearGradient(
																		colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
																	),
																	boxShadow: [
																		BoxShadow(
																			color:
																					const Color(0xFFFFD700).withOpacity(0.3),
																			blurRadius: 15,
																			offset: const Offset(0, 8),
																		),
																	],
																),
																child: ElevatedButton(
																	onPressed: _isLoading ? null : _register,
																	style: ElevatedButton.styleFrom(
																		backgroundColor: Colors.transparent,
																		shadowColor: Colors.transparent,
																		shape: RoundedRectangleBorder(
																			borderRadius: BorderRadius.circular(15.0),
																		),
																	),
																	child: _isLoading
																			? const CircularProgressIndicator(
																					color: Color(0xFF1A1A2E),
																				)
																			: Text(
																					AppConstants.createAccount,
																					style: TextStyle(
																						fontSize: 18,
																						fontWeight: FontWeight.bold,
																						color: Color(0xFF1A1A2E),
																					),
																				),
																),
															),

															const SizedBox(height: 30),

															// Divider
															Row(
																children: [
																	Expanded(
																		child: Container(
																			height: 1,
																			color: Colors.white.withOpacity(0.3),
																		),
																	),
																	Padding(
																		padding:
																				const EdgeInsets.symmetric(horizontal: 16),
																		child: Text(
																			AppConstants.orSignUpWith,
																			style: TextStyle(
																				color: Colors.white.withOpacity(0.8),
																				fontSize: 14,
																			),
																		),
																	),
																	Expanded(
																		child: Container(
																			height: 1,
																			color: Colors.white.withOpacity(0.3),
																		),
																	),
																],
															),

															const SizedBox(height: 30),

															// Botones de redes sociales
															Row(
																children: [
																	Expanded(
																		child: _buildSocialButton(
																			FontAwesomeIcons.google,
																			'Google',
																			Colors.red,
																			() {
																				ScaffoldMessenger.of(context).showSnackBar(
																					const SnackBar(
																						content: Text(
																							'Google registration coming soon',
																						),
																					),
																				);
																			},
																		),
																	),
																	const SizedBox(width: 16),
																	Expanded(
																		child: _buildSocialButton(
																			FontAwesomeIcons.facebookF,
																			'Facebook',
																			const Color(0xFF1877F2),
																			() {
																				ScaffoldMessenger.of(context).showSnackBar(
																					const SnackBar(
																						content: Text(
																							'Facebook registration coming soon',
																						),
																					),
																				);
																			},
																		),
																	),
																],
															),

															const SizedBox(height: 40),

															// Link para iniciar sesion
															Row(
																mainAxisAlignment: MainAxisAlignment.center,
																children: [
																	Text(
																		AppConstants.alreadyHaveAccount,
																		style: TextStyle(
																			color: Colors.white.withOpacity(0.8),
																			fontSize: 16,
																		),
																	),
																	GestureDetector(
																		onTap: () => Navigator.pop(context),
																		child: Text(
																			AppConstants.signIn,
																			style: const TextStyle(
																				color: Color(0xFFFFD700),
																				fontSize: 16,
																				fontWeight: FontWeight.bold,
																				decoration: TextDecoration.underline,
																			),
																		),
																	),
																],
															),
														],
													),
												),
											],
										),
									),
								),
							);
						},
					),
				),
			),
		);
	}

	Widget _buildSocialButton(
		IconData icon,
		String label,
		Color color,
		VoidCallback onPressed,
	) {
		return Container(
			height: 50,
			decoration: BoxDecoration(
				color: Colors.white.withOpacity(0.1),
				borderRadius: BorderRadius.circular(15.0),
				border: Border.all(color: Colors.white.withOpacity(0.2)),
			),
			child: TextButton(
				onPressed: onPressed,
				style: TextButton.styleFrom(
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(15.0),
					),
				),
				child: Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(icon, color: color, size: 20),
						const SizedBox(width: 8),
						Text(
							label,
							style: const TextStyle(
								color: Colors.white,
								fontSize: 14,
								fontWeight: FontWeight.w600,
							),
						),
					],
				),
			),
		);
	}
}
