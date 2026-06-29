class HybridLanguageLearner:
    """
    Neural networks learn language
    Evolutionary system discovers the rules they learned
    Rules feed back to improve networks
    """
    def __init__(self):
        # PRIMARY LEARNER: Modern neural network
        self.language_model = TransformerLanguageModel()
        
        # RULE DISCOVERY: Holland-inspired evolutionary system
        self.rule_discoverer = EvolutionaryRuleExtractor()
        self.discovered_rules = RuleLibrary()
        
        # INTEGRATION: Rules guide networks
        self.rule_guided_trainer = RuleGuidedLearning()
        
        # MEMORY: Conversation history
        self.interaction_buffer = ConversationMemory()
        
    def learning_cycle(self, human_teacher):
        """
        Main learning loop
        """
        # PHASE 1: Neural network learns from conversation
        conversation_data = self.converse_with_human(human_teacher, episodes=100)
        self.language_model.train_on(conversation_data)
        
        # PHASE 2: Discover rules from what network learned
        new_rules = self.rule_discoverer.extract_rules(
            self.language_model,
            conversation_data
        )
        
        # PHASE 3: Verify and consolidate rules
        verified_rules = self.verify_rules(new_rules, human_teacher)
        self.discovered_rules.add(verified_rules)
        
        # PHASE 4: Use rules to improve network
        self.rule_guided_trainer.incorporate_rules(
            self.language_model,
            self.discovered_rules
        )
        
        return self.discovered_rules

class ModernLanguageNetwork:
    """
    Use proven architectures for actual language learning
    Don't reinvent the wheel - use what works!
    """
    def __init__(self):
        # Use modern NLP architecture
        self.transformer = nn.Transformer(
            d_model=512,
            nhead=8,
            num_encoder_layers=6,
            num_decoder_layers=6
        )
        
        # Or simpler for conversational learning
        self.lstm = nn.LSTM(
            input_size=embedding_dim,
            hidden_size=512,
            num_layers=3,
            bidirectional=True
        )
        
        # Embeddings learned through conversation
        self.word_embeddings = nn.Embedding(vocab_size, embedding_dim)
        
    def learn_from_conversation(self, utterance, context, feedback):
        """
        Standard neural network training
        Uses gradient descent, not evolution
        """
        # Predict next word / response
        prediction = self.forward(utterance, context)
        
        # Learn from human feedback
        loss = self.compute_loss(prediction, feedback)
        loss.backward()
        self.optimizer.step()
        
        # THIS is what the network learns (implicitly)
        # The rule discovery system will make it explicit

class EvolutionaryRuleExtractor:
    """
    Evolve a population of rule hypotheses
    Find which rules explain the network's behavior
    """
    def __init__(self):
        # Population of rule hypotheses
        self.rule_population = []
        
        # Initialize with random linguistic hypotheses
        for _ in range(1000):
            self.rule_population.append(self.create_random_rule_hypothesis())
    
    def extract_rules(self, neural_network, training_data):
        """
        Discover what rules the neural network learned
        """
        print("Extracting rules from neural network...")
        
        # Run genetic algorithm to find rules
        for generation in range(100):
            # Evaluate: which rules explain network behavior?
            for rule in self.rule_population:
                rule.fitness = self.evaluate_rule_fit(
                    rule, neural_network, training_data
                )
            
            # Evolve: keep rules that explain the network well
            self.rule_population = self.genetic_algorithm_step(
                self.rule_population
            )
        
        # Return best discovered rules
        best_rules = self.get_top_rules(k=20)
        return best_rules
    
    def evaluate_rule_fit(self, rule, network, data):
        """
        How well does this rule explain what the network does?
        """
        agreement_score = 0
        
        for example in data:
            # What does the rule predict?
            rule_prediction = rule.apply(example.input)
            
            # What does the network predict?
            network_prediction = network.forward(example.input)
            
            # Do they agree?
            if self.predictions_match(rule_prediction, network_prediction):
                agreement_score += 1
            
            # Bonus: Does rule explain WHY network made this prediction?
            if rule.explains_activation_pattern(network, example.input):
                agreement_score += 0.5
        
        return agreement_score / len(data)
    
    def create_random_rule_hypothesis(self):
        """
        Create random linguistic rule hypothesis
        """
        rule_types = [
            self.create_syntax_rule,
            self.create_semantic_rule,
            self.create_morphology_rule,
            self.create_phonological_rule,
        ]
        
        rule_creator = random.choice(rule_types)
        return rule_creator()
    
    def create_syntax_rule(self):
        """
        Hypothesis about word order, phrase structure
        """
        patterns = [
            # Subject-Verb-Object order
            SyntaxRule(
                pattern=['SUBJ', 'VERB', 'OBJ'],
                constraint=lambda s, v, o: s.case == 'nominative',
                description="SVO word order"
            ),
            # Adjective before noun
            SyntaxRule(
                pattern=['ADJ', 'NOUN'],
                constraint=lambda adj, noun: adj.agrees_with(noun),
                description="Adjective-Noun order"
            ),
            # Auxiliary-Verb construction
            SyntaxRule(
                pattern=['AUX', 'VERB'],
                constraint=lambda aux, v: aux.agrees_with_subject(),
                description="Auxiliary verb construction"
            ),
        ]
        return random.choice(patterns)
    
    def create_semantic_rule(self):
        """
        Hypothesis about meaning composition
        """
        return SemanticRule(
            pattern=['VERB', 'NOUN'],
            composition=lambda v, n: Action(v.meaning, theme=n.meaning),
            description="Verb-theme composition"
        )
    
    def create_morphology_rule(self):
        """
        Hypothesis about word formation
        """
        return MorphologyRule(
            pattern="VERB + -ed",
            transformation=lambda v: PastTense(v),
            description="Past tense formation"
        )

class BidirectionalLearning:
    """
    Rules and networks inform each other
    This is the power of the hybrid approach
    """
    def __init__(self):
        self.neural_network = LanguageNetwork()
        self.rule_library = RuleLibrary()
        
    def neural_to_symbolic(self, network, data):
        """
        DIRECTION 1: Extract rules from network
        Network learned something → Discover what rule it is
        """
        # Analyze network's behavior
        behavioral_patterns = self.analyze_network_behavior(network, data)
        
        # Evolve rule hypotheses to explain patterns
        extractor = EvolutionaryRuleExtractor()
        discovered_rules = extractor.extract_rules(network, data)
        
        # Verify with human teacher
        for rule in discovered_rules:
            print(f"Did I discover this rule correctly?")
            print(f"  {rule.to_english()}")
            
            human_confirmation = input("Yes/No: ")
            if human_confirmation.lower() == 'yes':
                self.rule_library.add_verified(rule)
        
        return discovered_rules
    
    def symbolic_to_neural(self, rules, network):
        """
        DIRECTION 2: Use rules to guide network
        Rules discovered → Improve network architecture/training
        """
        # Method 1: Constrain network predictions
        network.add_rule_constraints(rules)
        
        # Method 2: Generate synthetic training data from rules
        synthetic_data = self.generate_data_from_rules(rules)
        network.train_on(synthetic_data)
        
        # Method 3: Modify network architecture based on rules
        network.add_rule_specific_modules(rules)
        
        # Method 4: Use rules for data augmentation
        augmented_data = self.augment_with_rules(training_data, rules)
        network.train_on(augmented_data)

class PastTenseDiscovery:
    """
    How the system would discover English past tense rules
    """
    def discover_past_tense(self, human_teacher):
        """
        Learning timeline
        """
        # PHASE 1: Neural network learns from examples
        print("=== Phase 1: Neural Learning ===")
        
        # Human teaches through conversation
        examples = [
            ("walk", "walked", "I walked to the store"),
            ("talk", "talked", "She talked to me"),
            ("play", "played", "They played yesterday"),
            ("jump", "jumped", "He jumped high"),
            # Irregular examples too
            ("go", "went", "I went home"),
            ("see", "saw", "I saw a bird"),
        ]
        
        # Network learns to predict past tense
        for present, past, sentence in examples:
            self.neural_network.train_on_example(present, past, sentence)
        
        # Network now implicitly knows past tense
        # But can't explain the rule!
        
        # PHASE 2: Evolutionary rule discovery
        print("\n=== Phase 2: Rule Discovery ===")
        
        # Create population of rule hypotheses
        rule_hypotheses = [
            # Regular past tense hypothesis
            MorphologyRule(
                pattern=lambda word: word.ends_with_consonant(),
                transformation=lambda word: word + "ed",
                applies_to=["walk", "talk", "jump"]
            ),
            
            # Vowel change hypothesis  
            MorphologyRule(
                pattern=lambda word: word in ["go", "see"],
                transformation=lambda word: self.irregular_lookup(word),
                applies_to=["go", "see"]
            ),
            
            # Wrong hypothesis (will be eliminated)
            MorphologyRule(
                pattern=lambda word: True,
                transformation=lambda word: word + "t",
                applies_to=[]  # Doesn't explain data
            ),
        ]
        
        # Evolve to find rules that match network behavior
        for generation in range(50):
            for rule in rule_hypotheses:
                # Test: Does this rule produce same outputs as network?
                rule.fitness = 0
                for present, past, _ in examples:
                    rule_output = rule.apply(present)
                    network_output = self.neural_network.predict_past_tense(present)
                    
                    if rule_output == network_output == past:
                        rule.fitness += 1
            
            # Evolve population
            rule_hypotheses = self.evolve_rules(rule_hypotheses)
        
        # Best rules discovered!
        best_rules = sorted(rule_hypotheses, key=lambda r: r.fitness, reverse=True)
        
        print("\n=== Discovered Rules ===")
        for rule in best_rules[:3]:
            print(f"RULE: {rule.description}")
            print(f"  Fitness: {rule.fitness}")
            print(f"  Examples: {rule.applies_to}")
        
        # PHASE 3: Verify with human
        print("\n=== Phase 3: Human Verification ===")
        for rule in best_rules[:3]:
            print(f"\nDid I discover this rule?")
            print(f"  {rule.to_english()}")
            
            # Test on new words
            test_words = ["kick", "push", "run"]
            for word in test_words:
                prediction = rule.apply(word)
                print(f"  {word} → {prediction}")
            
            confirmation = human_teacher.confirm_rule(rule)
            if confirmation:
                self.rule_library.add_verified(rule)
        
        # PHASE 4: Use rule to improve network
        print("\n=== Phase 4: Rule-Guided Improvement ===")
        
        # Generate synthetic training data from rule
        new_training_data = []
        regular_verbs = ["cook", "clean", "wash", "help"]
        for verb in regular_verbs:
            past = self.rule_library.apply_rules(verb)
            new_training_data.append((verb, past))
        
        # Train network on rule-generated data
        self.neural_network.train_on(new_training_data)
        
        # Network now generalizes better!

class RuleGuidedNeuralTraining:
    """
    Use discovered rules to improve neural network training
    """
    def __init__(self, neural_network, rule_library):
        self.network = neural_network
        self.rules = rule_library
    
    def train_with_rule_constraints(self, training_data):
        """
        Add rule constraints to network training
        """
        for batch in training_data:
            # Normal forward pass
            predictions = self.network.forward(batch.inputs)
            
            # Standard loss
            standard_loss = self.network.compute_loss(predictions, batch.targets)
            
            # Rule consistency loss
            rule_loss = 0
            for rule in self.rules.get_applicable_rules(batch):
                # Check if network predictions violate known rules
                rule_predictions = rule.apply_to_batch(batch.inputs)
                rule_violation = (predictions != rule_predictions).float().mean()
                rule_loss += rule_violation
            
            # Combined loss
            total_loss = standard_loss + 0.5 * rule_loss
            
            # Backprop
            total_loss.backward()
            self.network.optimizer.step()
    
    def generate_rule_based_data(self, rules):
        """
        Create synthetic training examples from rules
        Improves generalization!
        """
        synthetic_data = []
        
        for rule in rules:
            # Generate examples that follow this rule
            examples = rule.generate_examples(n=100)
            synthetic_data.extend(examples)
        
        return synthetic_data
    
    def architecture_from_rules(self, rules):
        """
        Modify network architecture based on discovered rules
        """
        # If we discovered a morphology rule, add morphology module
        if self.rules.has_morphology_rules():
            self.network.add_module(MorphologyModule())
        
        # If we discovered syntax rules, add syntax-aware attention
        if self.rules.has_syntax_rules():
            syntax_patterns = self.rules.get_syntax_patterns()
            self.network.add_structured_attention(syntax_patterns)

class CompleteHybridSystem:
    """
    Full implementation: Neural learning + Rule discovery
    """
    def __init__(self):
        # Modern neural network for language
        self.language_model = TransformerLanguageModel(
            vocab_size=50000,
            d_model=512,
            num_layers=6
        )
        
        # Holland-inspired rule discovery
        self.rule_discoverer = EvolutionaryRuleExtractor(
            population_size=1000,
            generations=100
        )
        
        # Discovered knowledge
        self.rule_library = RuleLibrary()
        
        # Integration
        self.rule_guided_trainer = RuleGuidedNeuralTraining(
            self.language_model,
            self.rule_library
        )
    
    def learn_language_from_human(self, human_teacher, sessions=100):
        """
        Complete learning process
        """
        for session in range(sessions):
            print(f"\n{'='*60}")
            print(f"Session {session + 1}")
            print(f"{'='*60}")
            
            # Step 1: Converse with human, network learns
            print("\n[1] Neural Learning Phase")
            conversation_data = self.conversational_session(human_teacher)
            self.language_model.train_on(conversation_data)
            
            # Step 2: Every N sessions, discover rules
            if session % 10 == 0:
                print("\n[2] Rule Discovery Phase")
                new_rules = self.rule_discoverer.extract_rules(
                    self.language_model,
                    conversation_data
                )
                
                # Step 3: Verify rules with human
                print("\n[3] Rule Verification Phase")
                verified_rules = self.verify_with_human(new_rules, human_teacher)
                self.rule_library.add_all(verified_rules)
                
                # Step 4: Use rules to improve network
                print("\n[4] Rule-Guided Improvement Phase")
                self.rule_guided_trainer.incorporate_rules(verified_rules)
            
            # Step 5: Report progress
            self.report_progress(session)
    
    def conversational_session(self, human_teacher, turns=20):
        """
        One conversation session
        """
        conversation_log = []
        
        for turn in range(turns):
            # Human says something
            human_utterance = human_teacher.speak()
            
            # Network responds
            context = self.build_context(conversation_log)
            response = self.language_model.generate_response(
                human_utterance,
                context
            )
            
            # Get feedback
            feedback = human_teacher.evaluate(response)
            
            # Log
            conversation_log.append({
                'human': human_utterance,
                'model': response,
                'feedback': feedback,
                'context': context
            })
            
            # If rule exists, check if we followed it
            applicable_rules = self.rule_library.get_applicable(human_utterance)
            for rule in applicable_rules:
                followed = rule.check_compliance(response)
                if not followed:
                    print(f"[WARNING] Violated rule: {rule.description}")
        
        return conversation_log
    
    def verify_with_human(self, candidate_rules, human_teacher):
        """
        Ask human to verify discovered rules
        """
        verified = []
        
        for rule in candidate_rules:
            print(f"\n{'='*60}")
            print("I think I discovered a rule:")
            print(f"  {rule.to_english()}")
            print(f"\nExamples:")
            
            for example in rule.examples[:5]:
                print(f"  {example}")
            
            print(f"\nIs this rule correct?")
            
            response = human_teacher.verify_rule(rule)
            
            if response.confirmed:
                verified.append(rule)
                print("✓ Rule added to knowledge base")
            else:
                print("✗ Rule rejected")
                if response.correction:
                    print(f"Human says: {response.correction}")
        
        return verified
    
    def report_progress(self, session):
        """
        Show current state
        """
        print(f"\n{'='*60}")
        print("PROGRESS REPORT")
        print(f"{'='*60}")
        print(f"Session: {session}")
        print(f"Vocabulary size: {len(self.language_model.vocabulary)}")
        print(f"Discovered rules: {len(self.rule_library)}")
        print(f"\nRule categories:")
        print(f"  Syntax rules: {self.rule_library.count_by_type('syntax')}")
        print(f"  Morphology rules: {self.rule_library.count_by_type('morphology')}")
        print(f"  Semantic rules: {self.rule_library.count_by_type('semantic')}")
        
        print(f"\nTop 5 rules:")
        for i, rule in enumerate(self.rule_library.get_top(5), 1):
            print(f"  {i}. {rule.description} (confidence: {rule.confidence:.2f})")

