import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../blocs/voice_command/voice_command_bloc.dart';

class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({super.key});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoiceCommandBloc, VoiceCommandState>(
      listener: (context, state) {
        if (state is VoiceCommandListening) {
          setState(() {
            _isListening = true;
          });
          _animationController.repeat();
          _showListeningDialog(context);
        } else {
          setState(() {
            _isListening = false;
          });
          _animationController.stop();
        }

        if (state is VoiceCommandSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Commande: ${state.result}')),
          );
        }

        if (state is VoiceCommandError) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return FloatingActionButton(
          onPressed: () {
            if (!_isListening) {
              context.read<VoiceCommandBloc>().add(StartListening());
            } else {
              context.read<VoiceCommandBloc>().add(StopListening());
            }
          },
          backgroundColor: _isListening ? AppColors.error : AppColors.primary,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Icon(
                _isListening ? Icons.stop : Icons.mic,
                size: 30,
                color: Colors.white,
              );
            },
          ),
        );
      },
    );
  }

  void _showListeningDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLight.withValues(alpha: 0.2),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 1.3),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.listening,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.speakNow,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  context.read<VoiceCommandBloc>().add(StopListening());
                  Navigator.of(dialogContext).pop();
                },
                child: Text(
                  'Annuler',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}