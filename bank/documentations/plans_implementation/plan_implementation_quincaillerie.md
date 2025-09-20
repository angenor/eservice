# 🔧 Plan d'Implémentation - Module Quincaillerie
## Application Mobile Flutter E-Service avec BLoC Pattern

---

## 📋 Vue d'Ensemble

### Objectif
Implémenter un module complet de quincaillerie permettant l'achat et la location de matériel de bricolage, avec système de conseil expert, génération de devis pour projets, calculateurs spécialisés, tutoriels intégrés et mise en relation avec des artisans professionnels.

### Durée estimée
**8-10 semaines** pour une implémentation complète avec tests

### Stack Technique
- **Frontend**: Flutter 3.x
- **Backend**: Supabase (PostgreSQL + PostGIS)
- **State Management**: BLoC Pattern (flutter_bloc 8.x)
- **Architecture**: Clean Architecture + BLoC + Repository Pattern
- **Video Call**: Agora SDK ou WebRTC
- **Chat**: Supabase Realtime
- **PDF Generation**: pdf package
- **Video Player**: video_player + youtube_player
- **Dependency Injection**: get_it + injectable

---

## 🏗️ Architecture du Projet

```
lib/
├── core/
│   ├── constants/
│   │   ├── hardware_categories.dart
│   │   ├── tool_types.dart
│   │   └── project_types.dart
│   ├── calculators/
│   │   ├── paint_calculator.dart
│   │   ├── cable_calculator.dart
│   │   ├── tile_calculator.dart
│   │   └── concrete_calculator.dart
│   ├── pdf/
│   │   ├── quote_generator.dart
│   │   └── invoice_generator.dart
│   └── injection/
│       └── injection.dart
│
├── features/
│   └── hardware/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── hardware_shop_remote_datasource.dart
│       │   │   ├── tool_remote_datasource.dart
│       │   │   ├── quote_remote_datasource.dart
│       │   │   ├── expert_remote_datasource.dart
│       │   │   ├── rental_remote_datasource.dart
│       │   │   └── artisan_remote_datasource.dart
│       │   ├── models/
│       │   │   ├── hardware_shop_model.dart
│       │   │   ├── tool_model.dart
│       │   │   ├── project_model.dart
│       │   │   ├── quote_model.dart
│       │   │   ├── expert_model.dart
│       │   │   ├── rental_model.dart
│       │   │   ├── tutorial_model.dart
│       │   │   └── artisan_model.dart
│       │   └── repositories/
│       │       ├── hardware_repository_impl.dart
│       │       ├── quote_repository_impl.dart
│       │       ├── expert_repository_impl.dart
│       │       └── rental_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── hardware_shop.dart
│       │   │   ├── tool.dart
│       │   │   ├── hardware_category.dart
│       │   │   ├── project.dart
│       │   │   ├── project_item.dart
│       │   │   ├── quote.dart
│       │   │   ├── rental.dart
│       │   │   ├── expert.dart
│       │   │   ├── consultation.dart
│       │   │   ├── tutorial.dart
│       │   │   └── artisan.dart
│       │   ├── repositories/
│       │   │   ├── hardware_repository.dart
│       │   │   ├── quote_repository.dart
│       │   │   ├── expert_repository.dart
│       │   │   └── rental_repository.dart
│       │   └── usecases/
│       │       ├── get_hardware_categories.dart
│       │       ├── search_tools.dart
│       │       ├── create_project.dart
│       │       ├── generate_quote.dart
│       │       ├── calculate_materials.dart
│       │       ├── check_tool_availability.dart
│       │       ├── book_expert_consultation.dart
│       │       ├── create_rental.dart
│       │       └── find_artisans.dart
│       │
│       └── presentation/
│           ├── blocs/
│           │   ├── tool_catalog/
│           │   │   ├── tool_catalog_bloc.dart
│           │   │   ├── tool_catalog_event.dart
│           │   │   └── tool_catalog_state.dart
│           │   ├── project_builder/
│           │   │   ├── project_builder_bloc.dart
│           │   │   ├── project_builder_event.dart
│           │   │   └── project_builder_state.dart
│           │   ├── quote/
│           │   │   ├── quote_bloc.dart
│           │   │   ├── quote_event.dart
│           │   │   └── quote_state.dart
│           │   ├── calculator/
│           │   │   ├── calculator_cubit.dart
│           │   │   └── calculator_state.dart
│           │   ├── expert_consultation/
│           │   │   ├── expert_consultation_bloc.dart
│           │   │   ├── expert_consultation_event.dart
│           │   │   └── expert_consultation_state.dart
│           │   ├── rental/
│           │   │   ├── rental_bloc.dart
│           │   │   ├── rental_event.dart
│           │   │   └── rental_state.dart
│           │   ├── artisan_finder/
│           │   │   ├── artisan_finder_cubit.dart
│           │   │   └── artisan_finder_state.dart
│           │   └── tutorial_player/
│           │       ├── tutorial_player_cubit.dart
│           │       └── tutorial_player_state.dart
│           ├── pages/
│           │   ├── hardware_home_page.dart
│           │   ├── category_tools_page.dart
│           │   ├── tool_details_page.dart
│           │   ├── project_builder_page.dart
│           │   ├── material_calculator_page.dart
│           │   ├── quote_details_page.dart
│           │   ├── expert_consultation_page.dart
│           │   ├── video_call_page.dart
│           │   ├── rental_page.dart
│           │   ├── tutorial_player_page.dart
│           │   ├── artisan_list_page.dart
│           │   └── hardware_cart_page.dart
│           └── widgets/
│               ├── tool_card.dart
│               ├── category_visual_grid.dart
│               ├── project_item_selector.dart
│               ├── quantity_calculator.dart
│               ├── rental_period_selector.dart
│               ├── price_comparison_widget.dart
│               ├── expert_card.dart
│               ├── consultation_booking_widget.dart
│               ├── quote_summary_card.dart
│               ├── tutorial_card.dart
│               ├── artisan_profile_card.dart
│               └── compatibility_checker.dart
│
└── main.dart
```

---

## 📊 Modèles de Données

### 1. Hardware Shop Entity
```dart
class HardwareShop {
  final String id;
  final String name;
  final Location location;
  final String address;
  final String? logoUrl;

  // Services
  final bool hasExpertConsultation;
  final bool hasToolRental;
  final bool hasDelivery;
  final bool hasPickup;
  final bool hasArtisanNetwork;

  // Business info
  final Map<String, TimeSlot> openingHours;
  final bool isOpen;
  final double rating;
  final int totalOrders;

  // Inventory
  final List<HardwareCategory> categories;
  final int totalProducts;
  final List<Brand> featuredBrands;
}
```

### 2. Tool Entity
```dart
class Tool {
  final String id;
  final String shopId;
  final String name;
  final String description;
  final List<String> images;
  final String barcode;

  // Category
  final HardwareCategory category;
  final ToolSubcategory subcategory;
  final List<String> tags;

  // Specifications
  final Map<String, dynamic> specifications;
  final String? brand;
  final String? model;
  final double? weight;
  final String? dimensions;

  // Purchase/Rental
  final double purchasePrice;
  final double? rentalPricePerDay;
  final double? rentalPricePerWeek;
  final bool isAvailableForRental;
  final bool isAvailableForPurchase;

  // Stock
  final int purchaseStock;
  final int rentalStock;
  final int currentlyRented;

  // Related
  final List<Tool>? compatibleTools;
  final List<Tool>? requiredAccessories;
  final List<String>? tutorialIds;

  // Volume pricing
  final Map<int, double>? volumePricing;

  bool get isAvailable =>
    (isAvailableForPurchase && purchaseStock > 0) ||
    (isAvailableForRental && rentalStock > currentlyRented);
}

enum HardwareCategory {
  tools,        // 🔨 Outils
  plumbing,     // 🚰 Plomberie
  electrical,   // ⚡ Électricité
  paint,        // 🎨 Peinture
  construction, // 🏗️ Construction
  garden,       // 🌿 Jardin
  safety        // 🦺 Sécurité
}

enum RentalPeriod {
  daily,
  weekly,
  monthly
}
```

### 3. Project Entity
```dart
class Project {
  final String id;
  final String userId;
  final String name;
  final ProjectType type;
  final String? description;
  final ProjectStatus status;

  // Items
  final List<ProjectItem> items;
  final Map<String, double> calculatedMaterials;

  // Expert consultation
  final String? expertId;
  final List<ExpertRecommendation> recommendations;

  // Pricing
  final double estimatedCost;
  final double finalCost;
  final Quote? quote;

  // Timeline
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? expectedEndDate;

  // Tutorials
  final List<Tutorial> relatedTutorials;

  double get totalCost => items.fold(0, (sum, item) =>
    sum + (item.unitPrice * item.quantity));

  bool get hasExpertValidation => expertId != null;
}

class ProjectItem {
  final String toolId;
  final String toolName;
  final int quantity;
  final double unitPrice;
  final bool isRental;
  final RentalPeriod? rentalPeriod;
  final int? rentalDuration;
  final String? notes;
  final bool isCompatible;
  final List<String>? incompatibilityReasons;
}

enum ProjectType {
  painting,      // Peinture
  plumbing,      // Plomberie
  electrical,    // Électrique
  tiling,        // Carrelage
  carpentry,     // Menuiserie
  masonry,       // Maçonnerie
  gardening,     // Jardinage
  general        // Général
}

enum ProjectStatus {
  draft,
  quotePending,
  quoteGenerated,
  inProgress,
  completed,
  cancelled
}
```

### 4. Quote Entity
```dart
class Quote {
  final String id;
  final String projectId;
  final String shopId;
  final String userId;

  // Items breakdown
  final List<QuoteItem> purchaseItems;
  final List<QuoteItem> rentalItems;

  // Pricing
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double taxAmount;
  final double totalAmount;

  // Details
  final String quoteNumber;
  final DateTime createdAt;
  final DateTime validUntil;
  final QuoteStatus status;
  final String? notes;

  // Sharing
  final String pdfUrl;
  final String shareableLink;

  bool get isValid => validUntil.isAfter(DateTime.now());
}

class QuoteItem {
  final String toolId;
  final String name;
  final String? description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final bool isRental;
  final RentalPeriod? rentalPeriod;
  final int? rentalDuration;
}

enum QuoteStatus {
  draft,
  sent,
  viewed,
  accepted,
  rejected,
  expired
}
```

### 5. Expert & Consultation Entity
```dart
class Expert {
  final String id;
  final String name;
  final String? photoUrl;
  final List<HardwareCategory> specialties;
  final double rating;
  final int totalConsultations;
  final double consultationRate;
  final List<TimeSlot> availability;
  final bool isOnline;
  final bool offersVideoCall;
  final bool offersChat;
  final String bio;
  final List<String> certifications;
}

class Consultation {
  final String id;
  final String userId;
  final String expertId;
  final String? projectId;

  // Type & timing
  final ConsultationType type;
  final DateTime scheduledAt;
  final int durationMinutes;
  final ConsultationStatus status;

  // Content
  final String topic;
  final String? description;
  final List<String>? attachedImages;

  // Outcome
  final String? expertNotes;
  final List<String>? recommendedTools;
  final double? estimatedProjectCost;

  // Call details (if video/audio)
  final String? callRoomId;
  final String? recordingUrl;
}

enum ConsultationType {
  chat,
  audioCall,
  videoCall,
  inStore
}

enum ConsultationStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow
}
```

### 6. Tutorial Entity
```dart
class Tutorial {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final TutorialSource source;

  // Metadata
  final ProjectType projectType;
  final DifficultyLevel difficulty;
  final int durationMinutes;
  final int viewCount;
  final double rating;

  // Required tools & materials
  final List<String> requiredToolIds;
  final Map<String, double> requiredMaterials;
  final double estimatedCost;

  // Chapters
  final List<TutorialChapter> chapters;
  final List<String> tips;
  final List<String> safetyWarnings;
}

class TutorialChapter {
  final String title;
  final int startTimeSeconds;
  final String? description;
}

enum TutorialSource {
  internal,
  youtube,
  vimeo
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  professional
}
```

### 7. Artisan Entity
```dart
class Artisan {
  final String id;
  final String name;
  final String? photoUrl;
  final String phone;
  final ArtisanType type;

  // Services
  final List<ProjectType> services;
  final String serviceArea;
  final double radius;

  // Experience
  final int yearsExperience;
  final String? businessLicense;
  final List<String> certifications;
  final List<String> portfolioImages;

  // Ratings
  final double rating;
  final int completedProjects;
  final int reviewCount;

  // Pricing
  final double hourlyRate;
  final double minimumCharge;
  final bool providesQuotes;

  // Availability
  final Map<String, TimeSlot> availability;
  final int averageResponseTime;
  final bool isAvailable;
}

enum ArtisanType {
  plumber,
  electrician,
  painter,
  carpenter,
  mason,
  generalContractor
}
```

---

## 🎨 Interfaces Principales

### 1. Page d'Accueil Quincaillerie
```dart
class HardwareHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ToolCatalogBloc>()
            ..add(LoadCategories()),
        ),
        BlocProvider(
          create: (context) => getIt<ProjectBuilderBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ExpertConsultationBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('🔧 Quincaillerie'),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () => _navigateToCart(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Need help section
              NeedHelpBanner(
                onChatPressed: () => _startExpertChat(context),
                onVideoCallPressed: () => _startVideoCall(context),
              ),

              // Visual categories
              VisualCategoryGrid(),

              // Active projects
              ActiveProjectsSection(),

              // Quick tools
              QuickToolsSection(),

              // Tutorials
              TutorialsCarousel(),

              // Find artisan
              FindArtisanCard(),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. Project Builder Page
```dart
class ProjectBuilderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProjectBuilderBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Créer un Projet'),
          actions: [
            TextButton(
              child: Text('Expert'),
              onPressed: () => _requestExpertHelp(context),
            ),
          ],
        ),
        body: BlocBuilder<ProjectBuilderBloc, ProjectBuilderState>(
          builder: (context, state) {
            return Stepper(
              currentStep: state.currentStep,
              onStepContinue: () => _nextStep(context),
              onStepCancel: () => _previousStep(context),
              steps: [
                // Step 1: Project Type
                Step(
                  title: Text('Type de Projet'),
                  content: ProjectTypeSelector(
                    selected: state.projectType,
                    onSelected: (type) {
                      context.read<ProjectBuilderBloc>()
                        .add(SelectProjectType(type));
                    },
                  ),
                ),

                // Step 2: Project Details
                Step(
                  title: Text('Détails'),
                  content: ProjectDetailsForm(
                    onDescriptionChanged: (desc) {
                      context.read<ProjectBuilderBloc>()
                        .add(UpdateProjectDescription(desc));
                    },
                  ),
                ),

                // Step 3: Material Calculator
                Step(
                  title: Text('Calculer Matériaux'),
                  content: MaterialCalculatorWidget(
                    projectType: state.projectType!,
                    onCalculated: (materials) {
                      context.read<ProjectBuilderBloc>()
                        .add(UpdateCalculatedMaterials(materials));
                    },
                  ),
                ),

                // Step 4: Tool Selection
                Step(
                  title: Text('Sélection Outils'),
                  content: ProjectToolSelector(
                    suggestedTools: state.suggestedTools,
                    selectedTools: state.selectedTools,
                    onToolToggled: (tool, selected) {
                      context.read<ProjectBuilderBloc>()
                        .add(ToggleTool(tool, selected));
                    },
                  ),
                ),

                // Step 5: Rental vs Purchase
                Step(
                  title: Text('Location vs Achat'),
                  content: RentalVsPurchaseComparison(
                    tools: state.selectedTools,
                    onDecisionMade: (decisions) {
                      context.read<ProjectBuilderBloc>()
                        .add(SetRentalDecisions(decisions));
                    },
                  ),
                ),

                // Step 6: Generate Quote
                Step(
                  title: Text('Devis'),
                  content: QuotePreview(
                    project: state.project,
                    onGenerateQuote: () {
                      context.read<ProjectBuilderBloc>()
                        .add(GenerateQuote());
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

---

## 🎯 BLoCs Principaux

### 1. Tool Catalog BLoC
```dart
// Events
abstract class ToolCatalogEvent extends Equatable {
  const ToolCatalogEvent();
}

class LoadCategories extends ToolCatalogEvent {}

class LoadCategoryTools extends ToolCatalogEvent {
  final HardwareCategory category;
  final ToolFilter? filter;

  const LoadCategoryTools(this.category, {this.filter});
}

class SearchTools extends ToolCatalogEvent {
  final String query;
  final SearchFilters? filters;

  const SearchTools(this.query, {this.filters});
}

class FilterByAvailability extends ToolCatalogEvent {
  final bool forPurchase;
  final bool forRental;

  const FilterByAvailability({
    this.forPurchase = true,
    this.forRental = true,
  });
}

// States
abstract class ToolCatalogState extends Equatable {
  const ToolCatalogState();
}

class CatalogInitial extends ToolCatalogState {}

class CatalogLoading extends ToolCatalogState {}

class CategoriesLoaded extends ToolCatalogState {
  final List<HardwareCategory> categories;
  final Map<HardwareCategory, int> toolCounts;

  const CategoriesLoaded({
    required this.categories,
    required this.toolCounts,
  });
}

class ToolsLoaded extends ToolCatalogState {
  final List<Tool> tools;
  final HardwareCategory? selectedCategory;
  final ToolFilter? activeFilter;
  final Map<String, bool> availability;

  const ToolsLoaded({
    required this.tools,
    this.selectedCategory,
    this.activeFilter,
    required this.availability,
  });

  List<Tool> get availableTools =>
    tools.where((t) => t.isAvailable).toList();

  List<Tool> get rentalTools =>
    tools.where((t) => t.isAvailableForRental).toList();
}

// BLoC
class ToolCatalogBloc extends Bloc<ToolCatalogEvent, ToolCatalogState> {
  final HardwareRepository repository;

  ToolCatalogBloc({required this.repository}) : super(CatalogInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadCategoryTools>(_onLoadCategoryTools);
    on<SearchTools>(_onSearchTools);
    on<FilterByAvailability>(_onFilterByAvailability);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<ToolCatalogState> emit,
  ) async {
    emit(CatalogLoading());

    try {
      final categories = await repository.getCategories();
      final counts = await repository.getCategoryCounts();

      emit(CategoriesLoaded(
        categories: categories,
        toolCounts: counts,
      ));
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }
}
```

### 2. Project Builder BLoC
```dart
// Events
abstract class ProjectBuilderEvent extends Equatable {
  const ProjectBuilderEvent();
}

class SelectProjectType extends ProjectBuilderEvent {
  final ProjectType type;
  const SelectProjectType(this.type);
}

class UpdateProjectDescription extends ProjectBuilderEvent {
  final String description;
  const UpdateProjectDescription(this.description);
}

class UpdateCalculatedMaterials extends ProjectBuilderEvent {
  final Map<String, double> materials;
  const UpdateCalculatedMaterials(this.materials);
}

class LoadSuggestedTools extends ProjectBuilderEvent {}

class ToggleTool extends ProjectBuilderEvent {
  final Tool tool;
  final bool selected;
  const ToggleTool(this.tool, this.selected);
}

class SetRentalDecisions extends ProjectBuilderEvent {
  final Map<String, RentalDecision> decisions;
  const SetRentalDecisions(this.decisions);
}

class GenerateQuote extends ProjectBuilderEvent {}

class SaveProject extends ProjectBuilderEvent {}

// State
class ProjectBuilderState extends Equatable {
  final int currentStep;
  final ProjectType? projectType;
  final String? description;
  final Map<String, double> calculatedMaterials;
  final List<Tool> suggestedTools;
  final List<Tool> selectedTools;
  final Map<String, RentalDecision> rentalDecisions;
  final Project? project;
  final Quote? quote;
  final bool isLoading;
  final String? error;

  const ProjectBuilderState({
    this.currentStep = 0,
    this.projectType,
    this.description,
    this.calculatedMaterials = const {},
    this.suggestedTools = const [],
    this.selectedTools = const [],
    this.rentalDecisions = const {},
    this.project,
    this.quote,
    this.isLoading = false,
    this.error,
  });

  double get estimatedCost {
    double total = 0;
    for (final tool in selectedTools) {
      final decision = rentalDecisions[tool.id];
      if (decision?.isRental ?? false) {
        total += (tool.rentalPricePerDay ?? 0) * (decision?.duration ?? 1);
      } else {
        total += tool.purchasePrice;
      }
    }
    return total;
  }

  ProjectBuilderState copyWith({
    int? currentStep,
    ProjectType? projectType,
    String? description,
    Map<String, double>? calculatedMaterials,
    List<Tool>? suggestedTools,
    List<Tool>? selectedTools,
    Map<String, RentalDecision>? rentalDecisions,
    Project? project,
    Quote? quote,
    bool? isLoading,
    String? error,
  }) {
    return ProjectBuilderState(
      currentStep: currentStep ?? this.currentStep,
      projectType: projectType ?? this.projectType,
      description: description ?? this.description,
      calculatedMaterials: calculatedMaterials ?? this.calculatedMaterials,
      suggestedTools: suggestedTools ?? this.suggestedTools,
      selectedTools: selectedTools ?? this.selectedTools,
      rentalDecisions: rentalDecisions ?? this.rentalDecisions,
      project: project ?? this.project,
      quote: quote ?? this.quote,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// BLoC
class ProjectBuilderBloc extends Bloc<ProjectBuilderEvent, ProjectBuilderState> {
  final CreateProject createProject;
  final GenerateQuote generateQuote;
  final CalculateMaterials calculateMaterials;

  ProjectBuilderBloc({
    required this.createProject,
    required this.generateQuote,
    required this.calculateMaterials,
  }) : super(const ProjectBuilderState()) {
    on<SelectProjectType>(_onSelectProjectType);
    on<UpdateCalculatedMaterials>(_onUpdateMaterials);
    on<LoadSuggestedTools>(_onLoadSuggestedTools);
    on<GenerateQuote>(_onGenerateQuote);
  }

  Future<void> _onSelectProjectType(
    SelectProjectType event,
    Emitter<ProjectBuilderState> emit,
  ) async {
    emit(state.copyWith(
      projectType: event.type,
      currentStep: state.currentStep + 1,
    ));

    // Load suggested tools for this project type
    add(LoadSuggestedTools());
  }

  Future<void> _onGenerateQuote(
    GenerateQuote event,
    Emitter<ProjectBuilderState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Create project
      final project = await createProject(
        ProjectParams(
          name: 'Projet ${state.projectType?.name}',
          type: state.projectType!,
          description: state.description,
          items: state.selectedTools.map((tool) {
            final decision = state.rentalDecisions[tool.id];
            return ProjectItem(
              toolId: tool.id,
              toolName: tool.name,
              quantity: 1,
              unitPrice: decision?.isRental ?? false
                ? tool.rentalPricePerDay ?? 0
                : tool.purchasePrice,
              isRental: decision?.isRental ?? false,
              rentalPeriod: decision?.period,
              rentalDuration: decision?.duration,
            );
          }).toList(),
          calculatedMaterials: state.calculatedMaterials,
        ),
      );

      // Generate quote
      final quote = await generateQuote(QuoteParams(projectId: project.id));

      emit(state.copyWith(
        project: project,
        quote: quote,
        isLoading: false,
        currentStep: state.currentStep + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la génération du devis',
      ));
    }
  }
}
```

### 3. Calculator Cubit
```dart
class CalculatorState extends Equatable {
  final CalculatorType? activeCalculator;
  final Map<String, double> inputs;
  final Map<String, double> results;
  final List<String> requiredMaterials;
  final double estimatedCost;
  final bool isCalculating;

  const CalculatorState({
    this.activeCalculator,
    this.inputs = const {},
    this.results = const {},
    this.requiredMaterials = const [],
    this.estimatedCost = 0.0,
    this.isCalculating = false,
  });
}

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit() : super(const CalculatorState());

  void selectCalculator(CalculatorType type) {
    emit(state.copyWith(
      activeCalculator: type,
      inputs: {},
      results: {},
    ));
  }

  void updateInput(String key, double value) {
    final updatedInputs = Map<String, double>.from(state.inputs);
    updatedInputs[key] = value;

    emit(state.copyWith(inputs: updatedInputs));

    // Auto-calculate on input change
    _calculate();
  }

  void _calculate() {
    emit(state.copyWith(isCalculating: true));

    switch (state.activeCalculator) {
      case CalculatorType.paint:
        _calculatePaint();
        break;
      case CalculatorType.tile:
        _calculateTile();
        break;
      case CalculatorType.cable:
        _calculateCable();
        break;
      case CalculatorType.concrete:
        _calculateConcrete();
        break;
      default:
        break;
    }
  }

  void _calculatePaint() {
    final area = state.inputs['area'] ?? 0;
    final coats = state.inputs['coats'] ?? 2;
    final coverage = 10; // m² per liter

    final litersNeeded = (area * coats) / coverage;
    final bucketsNeeded = (litersNeeded / 5).ceil(); // 5L buckets

    emit(state.copyWith(
      results: {
        'liters': litersNeeded,
        'buckets': bucketsNeeded.toDouble(),
      },
      requiredMaterials: [
        '${bucketsNeeded} seaux de peinture (5L)',
        '1 kit de rouleaux',
        'Bâche de protection',
      ],
      estimatedCost: bucketsNeeded * 25000, // 25000 FCFA per bucket
      isCalculating: false,
    ));
  }

  void _calculateTile() {
    final area = state.inputs['area'] ?? 0;
    final tileSize = state.inputs['tileSize'] ?? 0.36; // 60x60cm = 0.36m²
    final waste = 0.1; // 10% waste

    final tilesNeeded = (area / tileSize) * (1 + waste);
    final boxesNeeded = (tilesNeeded / 10).ceil(); // 10 tiles per box
    final adhesiveBags = (area / 5).ceil(); // 5m² per bag
    final groutBags = (area / 10).ceil(); // 10m² per bag

    emit(state.copyWith(
      results: {
        'tiles': tilesNeeded,
        'boxes': boxesNeeded.toDouble(),
        'adhesive': adhesiveBags.toDouble(),
        'grout': groutBags.toDouble(),
      },
      requiredMaterials: [
        '${boxesNeeded} boîtes de carreaux',
        '${adhesiveBags} sacs de colle',
        '${groutBags} sacs de joint',
        'Croisillons',
        'Niveau à bulle',
      ],
      estimatedCost: (boxesNeeded * 15000) + (adhesiveBags * 8000) + (groutBags * 5000),
      isCalculating: false,
    ));
  }
}

enum CalculatorType {
  paint,
  tile,
  cable,
  concrete
}
```

### 4. Expert Consultation BLoC
```dart
// Events
abstract class ExpertConsultationEvent extends Equatable {
  const ExpertConsultationEvent();
}

class LoadAvailableExperts extends ExpertConsultationEvent {
  final HardwareCategory? specialty;

  const LoadAvailableExperts({this.specialty});
}

class SelectExpert extends ExpertConsultationEvent {
  final Expert expert;

  const SelectExpert(this.expert);
}

class BookConsultation extends ExpertConsultationEvent {
  final String expertId;
  final ConsultationType type;
  final DateTime scheduledAt;
  final String topic;

  const BookConsultation({
    required this.expertId,
    required this.type,
    required this.scheduledAt,
    required this.topic,
  });
}

class StartVideoCall extends ExpertConsultationEvent {
  final String consultationId;

  const StartVideoCall(this.consultationId);
}

class SendChatMessage extends ExpertConsultationEvent {
  final String message;
  final List<String>? images;

  const SendChatMessage(this.message, {this.images});
}

// States
abstract class ExpertConsultationState extends Equatable {
  const ExpertConsultationState();
}

class ConsultationInitial extends ExpertConsultationState {}

class ExpertsLoading extends ExpertConsultationState {}

class ExpertsLoaded extends ExpertConsultationState {
  final List<Expert> experts;
  final Expert? selectedExpert;

  const ExpertsLoaded({
    required this.experts,
    this.selectedExpert,
  });

  List<Expert> get onlineExperts =>
    experts.where((e) => e.isOnline).toList();
}

class ConsultationBooked extends ExpertConsultationState {
  final Consultation consultation;

  const ConsultationBooked(this.consultation);
}

class ConsultationInProgress extends ExpertConsultationState {
  final Consultation consultation;
  final String? callRoomId;
  final List<ChatMessage> messages;

  const ConsultationInProgress({
    required this.consultation,
    this.callRoomId,
    this.messages = const [],
  });
}

// BLoC
class ExpertConsultationBloc extends Bloc<ExpertConsultationEvent, ExpertConsultationState> {
  final ExpertRepository expertRepository;
  final BookExpertConsultation bookConsultation;
  StreamSubscription? _chatSubscription;

  ExpertConsultationBloc({
    required this.expertRepository,
    required this.bookConsultation,
  }) : super(ConsultationInitial()) {
    on<LoadAvailableExperts>(_onLoadExperts);
    on<BookConsultation>(_onBookConsultation);
    on<StartVideoCall>(_onStartVideoCall);
    on<SendChatMessage>(_onSendChatMessage);
  }

  Future<void> _onLoadExperts(
    LoadAvailableExperts event,
    Emitter<ExpertConsultationState> emit,
  ) async {
    emit(ExpertsLoading());

    try {
      final experts = await expertRepository.getAvailableExperts(
        specialty: event.specialty,
      );

      emit(ExpertsLoaded(experts: experts));
    } catch (e) {
      emit(ConsultationError(e.toString()));
    }
  }

  Future<void> _onStartVideoCall(
    StartVideoCall event,
    Emitter<ExpertConsultationState> emit,
  ) async {
    try {
      // Initialize Agora/WebRTC
      final roomId = await expertRepository.createVideoCallRoom(
        event.consultationId,
      );

      if (state is ConsultationInProgress) {
        emit((state as ConsultationInProgress).copyWith(
          callRoomId: roomId,
        ));
      }
    } catch (e) {
      emit(ConsultationError('Erreur lors du démarrage de l\'appel'));
    }
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }
}
```

### 5. Rental BLoC
```dart
// Events
abstract class RentalEvent extends Equatable {
  const RentalEvent();
}

class CheckToolAvailability extends RentalEvent {
  final String toolId;
  final DateTime startDate;
  final DateTime endDate;

  const CheckToolAvailability({
    required this.toolId,
    required this.startDate,
    required this.endDate,
  });
}

class CreateRental extends RentalEvent {
  final List<RentalItem> items;
  final DateTime startDate;
  final DateTime endDate;

  const CreateRental({
    required this.items,
    required this.startDate,
    required this.endDate,
  });
}

class ExtendRental extends RentalEvent {
  final String rentalId;
  final DateTime newEndDate;

  const ExtendRental(this.rentalId, this.newEndDate);
}

// State
class RentalState extends Equatable {
  final List<Tool> availableTools;
  final Map<String, bool> availability;
  final List<RentalItem> selectedItems;
  final DateTimeRange? selectedPeriod;
  final double totalCost;
  final Rental? activeRental;
  final bool isLoading;

  const RentalState({
    this.availableTools = const [],
    this.availability = const {},
    this.selectedItems = const [],
    this.selectedPeriod,
    this.totalCost = 0.0,
    this.activeRental,
    this.isLoading = false,
  });

  int get totalDays => selectedPeriod != null
    ? selectedPeriod!.end.difference(selectedPeriod!.start).inDays + 1
    : 0;
}

// BLoC
class RentalBloc extends Bloc<RentalEvent, RentalState> {
  final RentalRepository rentalRepository;

  RentalBloc({required this.rentalRepository}) : super(const RentalState()) {
    on<CheckToolAvailability>(_onCheckAvailability);
    on<CreateRental>(_onCreateRental);
    on<ExtendRental>(_onExtendRental);
  }

  Future<void> _onCheckAvailability(
    CheckToolAvailability event,
    Emitter<RentalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final isAvailable = await rentalRepository.checkAvailability(
        toolId: event.toolId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      final updatedAvailability = Map<String, bool>.from(state.availability);
      updatedAvailability[event.toolId] = isAvailable;

      emit(state.copyWith(
        availability: updatedAvailability,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
```

---

## 🎨 Widgets Spécialisés

### 1. Visual Category Grid
```dart
class VisualCategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      CategoryItem('🔨', 'Outils', HardwareCategory.tools),
      CategoryItem('🚰', 'Plomberie', HardwareCategory.plumbing),
      CategoryItem('⚡', 'Électricité', HardwareCategory.electrical),
      CategoryItem('🎨', 'Peinture', HardwareCategory.paint),
      CategoryItem('🏗️', 'Construction', HardwareCategory.construction),
      CategoryItem('🌿', 'Jardin', HardwareCategory.garden),
      CategoryItem('🦺', 'Sécurité', HardwareCategory.safety),
      CategoryItem('🪜', 'Location', null, isRental: true),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        return GestureDetector(
          onTap: () {
            if (category.isRental) {
              Navigator.pushNamed(context, '/rental');
            } else {
              Navigator.pushNamed(
                context,
                '/category-tools',
                arguments: category.type,
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.emoji,
                  style: TextStyle(fontSize: 28),
                ),
                SizedBox(height: 8),
                Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### 2. Rental vs Purchase Comparison
```dart
class RentalVsPurchaseComparison extends StatelessWidget {
  final List<Tool> tools;
  final Function(Map<String, RentalDecision>) onDecisionMade;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: tool.images.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tool.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            tool.brand ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Comparison
                Row(
                  children: [
                    // Purchase option
                    Expanded(
                      child: ComparisonCard(
                        title: 'Achat',
                        price: '${tool.purchasePrice} FCFA',
                        advantages: [
                          'Propriété permanente',
                          'Usage illimité',
                          'Possibilité de revente',
                        ],
                        isSelected: false,
                        onTap: () => _selectPurchase(tool),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Rental option
                    Expanded(
                      child: ComparisonCard(
                        title: 'Location',
                        price: '${tool.rentalPricePerDay} FCFA/jour',
                        advantages: [
                          'Coût initial faible',
                          'Pas de stockage',
                          'Maintenance incluse',
                        ],
                        isSelected: false,
                        onTap: () => _selectRental(tool),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Recommendation
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getRecommendation(tool),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getRecommendation(Tool tool) {
    final breakEvenDays = tool.purchasePrice / (tool.rentalPricePerDay ?? 1);

    if (breakEvenDays < 7) {
      return 'Recommandé: Achat (rentable dès $breakEvenDays jours)';
    } else if (breakEvenDays < 30) {
      return 'Location conseillée pour usage < ${breakEvenDays.round()} jours';
    } else {
      return 'Location recommandée pour usage ponctuel';
    }
  }
}
```

### 3. Material Calculator Widget
```dart
class MaterialCalculatorWidget extends StatelessWidget {
  final ProjectType projectType;
  final Function(Map<String, double>) onCalculated;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CalculatorCubit>()
        ..selectCalculator(_getCalculatorType(projectType)),
      child: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input fields
              _buildInputFields(context, state),

              SizedBox(height: 24),

              // Results
              if (state.results.isNotEmpty) ...[
                Text(
                  'Matériaux nécessaires',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),

                ...state.requiredMaterials.map((material) =>
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(material),
                  ),
                ),

                Divider(height: 32),

                // Cost estimation
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Coût estimé matériaux',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${state.estimatedCost} FCFA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Save button
                ElevatedButton.icon(
                  onPressed: () => onCalculated(state.results),
                  icon: Icon(Icons.save),
                  label: Text('Utiliser ces calculs'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputFields(BuildContext context, CalculatorState state) {
    switch (state.activeCalculator) {
      case CalculatorType.paint:
        return Column(
          children: [
            NumberInputField(
              label: 'Surface à peindre (m²)',
              value: state.inputs['area'],
              onChanged: (value) {
                context.read<CalculatorCubit>().updateInput('area', value);
              },
            ),
            NumberInputField(
              label: 'Nombre de couches',
              value: state.inputs['coats'],
              onChanged: (value) {
                context.read<CalculatorCubit>().updateInput('coats', value);
              },
            ),
          ],
        );
      case CalculatorType.tile:
        return Column(
          children: [
            NumberInputField(
              label: 'Surface à carreler (m²)',
              value: state.inputs['area'],
              onChanged: (value) {
                context.read<CalculatorCubit>().updateInput('area', value);
              },
            ),
            TileSizeSelector(
              selected: state.inputs['tileSize'],
              onChanged: (size) {
                context.read<CalculatorCubit>().updateInput('tileSize', size);
              },
            ),
          ],
        );
      default:
        return Container();
    }
  }

  CalculatorType _getCalculatorType(ProjectType projectType) {
    switch (projectType) {
      case ProjectType.painting:
        return CalculatorType.paint;
      case ProjectType.tiling:
        return CalculatorType.tile;
      case ProjectType.electrical:
        return CalculatorType.cable;
      case ProjectType.masonry:
        return CalculatorType.concrete;
      default:
        return CalculatorType.paint;
    }
  }
}
```

---

## 📅 Planning de Développement

### Sprint 1 (Semaine 1-2): Foundation
- [ ] Setup projet avec BLoC
- [ ] Structure Clean Architecture
- [ ] Modèles hardware et outils
- [ ] Configuration Supabase
- [ ] Setup calculateurs de base

### Sprint 2 (Semaine 3-4): Catalog & Tools
- [ ] Tool catalog BLoC
- [ ] Categories navigation
- [ ] Tool details page
- [ ] Search & filters
- [ ] Compatibility checker

### Sprint 3 (Semaine 5-6): Project Builder
- [ ] Project builder BLoC
- [ ] Material calculators
- [ ] Tool suggestions
- [ ] Rental vs purchase comparison
- [ ] Project save/load

### Sprint 4 (Semaine 7): Quote & Expert
- [ ] Quote generation
- [ ] PDF export
- [ ] Expert consultation booking
- [ ] Chat implementation
- [ ] Video call setup

### Sprint 5 (Semaine 8-9): Rental & Artisan
- [ ] Rental system
- [ ] Availability checker
- [ ] Artisan finder
- [ ] Tutorial integration
- [ ] Order finalization

### Sprint 6 (Semaine 10): Polish & Testing
- [ ] Integration tests
- [ ] UI polish
- [ ] Performance optimization
- [ ] Documentation
- [ ] Beta testing

---

## 🚨 Points d'Attention Spécifiques

### 1. Calculateurs Précision
- Prévoir marge d'erreur 10%
- Sauvegarder historique calculs
- Export PDF des calculs
- Validation par expert possible

### 2. Compatibilité Outils
```dart
class CompatibilityChecker {
  static List<String> checkCompatibility(Tool tool1, Tool tool2) {
    final issues = <String>[];

    // Check power compatibility
    if (tool1.specifications['voltage'] != tool2.specifications['voltage']) {
      issues.add('Tension incompatible');
    }

    // Check connector compatibility
    if (!_areConnectorsCompatible(tool1, tool2)) {
      issues.add('Connecteurs incompatibles');
    }

    return issues;
  }
}
```

### 3. Video Call Integration
- Agora SDK pour appels vidéo
- Fallback sur appel audio
- Recording optionnel (avec accord)
- Chat pendant l'appel

---

## ✅ Checklist Module Quincaillerie

### MVP Features
- [ ] Catalogue outils par catégorie
- [ ] Calculateurs matériaux
- [ ] Système de devis
- [ ] Location vs achat
- [ ] Chat expert

### Features Avancées
- [ ] Video call expert
- [ ] Tutoriels intégrés
- [ ] Mise en relation artisans
- [ ] Projets sauvegardés
- [ ] Recommandations IA

---

## 📦 Packages Spécifiques

```yaml
dependencies:
  # Video Call
  agora_rtc_engine: dernière_version_stable

  # PDF Generation
  pdf: dernière_version_stable
  printing: dernière_version_stable

  # Video Player
  video_player: dernière_version_stable
  youtube_player_flutter: dernière_version_stable

  # Chat UI
  dash_chat_2: dernière_version_stable
```

---

*Ce plan d'implémentation pour le module quincaillerie offre une expérience complète de conseil, calcul et achat/location de matériel de bricolage avec BLoC Pattern et intégration d'expertise métier.*