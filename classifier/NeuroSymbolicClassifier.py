class NeuroSymbolicClassifier:
    """
    Combines neural networks with symbolic rule discovery
    Holland LCS + Neural Networks
    """
    def __init__(self, input_dim, output_dim, population_size=100):
        # Neural network population (subsymbolic)
        self.networks = [NeuralNetwork(input_dim, output_dim) 
                        for _ in range(population_size)]
        
        # Discovered rules (symbolic)
        self.rule_base = RuleBase()
        
        # Hybrid evaluators
        self.rule_extractors = []
        self.credit_assignment = HybridBucketBrigade()
        
    def evolve(self, environment, generations):
        for gen in range(generations):
            # 1. Neural networks learn and act
            self.neural_learning_phase(environment)
            
            # 2. Extract rules from successful networks
            self.rule_extraction_phase()
            
            # 3. Evolve both networks and rules
            self.genetic_phase()
            
            # 4. Rules guide next generation of networks
            self.rule_guided_mutation()

class NeuralConditionAction:
    """
    Neural network that evaluates conditions and generates actions
    Like Holland's classifier but with neural computation
    """
    def __init__(self, input_dim, hidden_dim, output_dim):
        # Condition network: evaluates if rule should fire
        self.condition_net = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, 1),
            nn.Sigmoid()  # Probability this classifier matches
        )
        
        # Action network: what to do if condition met
        self.action_net = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, output_dim)
        )
        
        # Rule metadata (Holland-style)
        self.strength = 1.0  # Fitness/utility
        self.specificity = 0.0  # How specific this classifier is
        self.extracted_rule = None  # Symbolic rule if discovered
        
    def evaluate(self, state):
        """Returns (should_fire, action, confidence)"""
        condition_strength = self.condition_net(state)
        action = self.action_net(state)
        return condition_strength, action
    
    def matches(self, state, threshold=0.5):
        """Like Holland's string matching but fuzzy"""
        strength = self.condition_net(state)
        return strength > threshold

class RuleExtractor:
    """
    Extract interpretable IF-THEN rules from trained neural networks
    """
    def extract_rules(self, network, training_data, labels):
        """
        Multiple approaches to rule extraction
        """
        rules = []
        
        # Method 1: Decision tree approximation
        rules.extend(self.tree_extraction(network, training_data, labels))
        
        # Method 2: Activation pattern analysis
        rules.extend(self.activation_analysis(network, training_data))
        
        # Method 3: Gradient-based saliency
        rules.extend(self.saliency_rules(network, training_data))
        
        return rules
    
    def tree_extraction(self, network, data, labels):
        """
        Train decision tree to mimic neural network
        Extract rules from tree
        """
        # Get neural network predictions
        nn_predictions = [network.forward(x) for x in data]
        
        # Train decision tree to approximate NN
        from sklearn.tree import DecisionTreeClassifier
        tree = DecisionTreeClassifier(max_depth=5)
        tree.fit(data, nn_predictions)
        
        # Extract rules from tree
        rules = self.tree_to_rules(tree)
        return rules
    
    def activation_analysis(self, network, data):
        """
        Analyze which input patterns activate which neurons
        Create rules based on activation patterns
        """
        rules = []
        
        # Collect activation patterns
        activations = self.get_hidden_activations(network, data)
        
        # Cluster activation patterns
        from sklearn.cluster import KMeans
        kmeans = KMeans(n_clusters=10)
        clusters = kmeans.fit_predict(activations)
        
        # Create rule for each cluster
        for cluster_id in range(10):
            cluster_data = data[clusters == cluster_id]
            rule = self.create_rule_from_cluster(cluster_data, cluster_id)
            rules.append(rule)
        
        return rules
    
    def saliency_rules(self, network, data):
        """
        Use gradient saliency to find important features
        Create rules based on feature importance
        """
        rules = []
        
        for class_id in range(network.output_dim):
            # Find most important features for this class
            important_features = self.get_salient_features(
                network, data, class_id
            )
            
            # Create rule: IF important_features THEN class_id
            rule = Rule(
                conditions=important_features,
                action=class_id,
                confidence=0.8
            )
            rules.append(rule)
        
        return rules

class Rule:
    """
    Symbolic rule like Holland's classifiers
    But discovered from neural networks
    """
    def __init__(self, conditions, action, confidence):
        self.conditions = conditions  # List of (feature, operator, value)
        self.action = action
        self.confidence = confidence
        self.strength = 1.0  # Holland-style strength
        self.usage_count = 0
        
    def matches(self, state):
        """Check if all conditions are satisfied"""
        for feature_idx, operator, threshold in self.conditions:
            feature_value = state[feature_idx]
            
            if operator == '>':
                if feature_value <= threshold:
                    return False
            elif operator == '<':
                if feature_value >= threshold:
                    return False
            elif operator == '==':
                if abs(feature_value - threshold) > 0.1:
                    return False
        
        return True
    
    def to_string(self):
        """Human-readable rule"""
        cond_str = " AND ".join([
            f"feature_{idx} {op} {val:.2f}" 
            for idx, op, val in self.conditions
        ])
        return f"IF {cond_str} THEN action={self.action} (conf={self.confidence:.2f})"

class HybridRuleBase:
    """
    Both symbolic rules and neural networks compete to classify
    Like Holland's classifier system but hybrid
    """
    def __init__(self):
        self.symbolic_rules = []
        self.neural_classifiers = []
        
    def classify(self, state):
        """
        Both rules and networks bid for the right to classify
        Holland's auction mechanism applied to hybrid system
        """
        bids = []
        
        # Symbolic rules bid
        for rule in self.symbolic_rules:
            if rule.matches(state):
                bid = rule.strength * rule.confidence
                bids.append((bid, 'rule', rule, rule.action))
        
        # Neural networks bid
        for network in self.neural_classifiers:
            condition_strength, action = network.evaluate(state)
            bid = network.strength * condition_strength
            bids.append((bid, 'network', network, action))
        
        if not bids:
            # Random fallback
            return random.choice(range(self.num_classes))
        
        # Winner takes all (or could use voting)
        bids.sort(reverse=True)
        winning_bid, winner_type, winner, action = bids[0]
        
        return action, winner
    
    def update_credits(self, winners, reward):
        """
        Holland's bucket brigade for hybrid system
        """
        for winner in winners:
            if isinstance(winner, Rule):
                winner.strength += reward * 0.1
                winner.usage_count += 1
            elif isinstance(winner, NeuralConditionAction):
                winner.strength += reward * 0.1

class HybridGeneticAlgorithm:
    """
    Evolve both neural networks AND symbolic rules
    """
    def __init__(self):
        self.rule_ga = RuleGeneticAlgorithm()
        self.network_ga = NetworkGeneticAlgorithm()
        
    def evolve_generation(self, population, environment):
        """
        Co-evolve rules and networks
        """
        # Separate into rules and networks
        rules = [ind for ind in population if isinstance(ind, Rule)]
        networks = [ind for ind in population if isinstance(ind, NeuralConditionAction)]
        
        # Evaluate both
        self.evaluate_all(population, environment)
        
        # Evolve rules using GP-style operators
        new_rules = self.evolve_rules(rules)
        
        # Evolve networks using neuroevolution
        new_networks = self.evolve_networks(networks)
        
        # Rules can spawn networks and vice versa
        hybrid_offspring = self.cross_pollinate(rules, networks)
        
        return new_rules + new_networks + hybrid_offspring
    
    def evolve_rules(self, rules):
        """Genetic programming on symbolic rules"""
        offspring = []
        
        # Selection
        parents = tournament_selection(rules, k=len(rules))
        
        for i in range(0, len(parents), 2):
            if i+1 < len(parents):
                # Crossover: exchange conditions between rules
                child1, child2 = self.rule_crossover(parents[i], parents[i+1])
                
                # Mutation: modify conditions
                child1 = self.rule_mutation(child1)
                child2 = self.rule_mutation(child2)
                
                offspring.extend([child1, child2])
        
        return offspring
    
    def rule_crossover(self, rule1, rule2):
        """Exchange conditions between rules"""
        # Split conditions
        split1 = len(rule1.conditions) // 2
        split2 = len(rule2.conditions) // 2
        
        child1_conditions = rule1.conditions[:split1] + rule2.conditions[split2:]
        child2_conditions = rule2.conditions[:split2] + rule1.conditions[split1:]
        
        child1 = Rule(child1_conditions, rule1.action, rule1.confidence)
        child2 = Rule(child2_conditions, rule2.action, rule2.confidence)
        
        return child1, child2
    
    def rule_mutation(self, rule):
        """Modify rule conditions"""
        if random.random() < 0.1:
            # Add new condition
            new_condition = (
                random.randint(0, 10),  # feature index
                random.choice(['>', '<', '==']),
                random.uniform(-1, 1)
            )
            rule.conditions.append(new_condition)
        
        if len(rule.conditions) > 1 and random.random() < 0.1:
            # Remove a condition
            rule.conditions.pop(random.randint(0, len(rule.conditions)-1))
        
        # Modify existing conditions
        for i in range(len(rule.conditions)):
            if random.random() < 0.1:
                feature_idx, operator, threshold = rule.conditions[i]
                threshold += random.gauss(0, 0.1)
                rule.conditions[i] = (feature_idx, operator, threshold)
        
        return rule
    
    def cross_pollinate(self, rules, networks):
        """
        Create new individuals that combine rules and networks
        """
        offspring = []
        
        # Convert successful rules into neural network architectures
        for rule in rules[:5]:  # Top rules
            if rule.strength > 1.5:
                network = self.rule_to_network(rule)
                offspring.append(network)
        
        # Convert successful networks into rules
        for network in networks[:5]:  # Top networks
            if network.strength > 1.5:
                extractor = RuleExtractor()
                # Would need training data here
                # new_rules = extractor.extract_rules(network, data, labels)
                # offspring.extend(new_rules)
                pass
        
        return offspring
    
    def rule_to_network(self, rule):
        """
        Create a neural network that implements a symbolic rule
        """
        # Create a network with architecture inspired by rule
        network = NeuralConditionAction(
            input_dim=10,
            hidden_dim=len(rule.conditions) * 2,
            output_dim=5
        )
        
        # Initialize weights to approximately implement the rule
        # This is a form of knowledge transfer
        self.initialize_from_rule(network, rule)
        
        return network
class NeuroSymbolicEvolutionaryClassifier:
    """
    Complete system: Holland's LCS + Neural Networks + Rule Discovery
    """
    def __init__(self, input_dim, output_dim):
        self.input_dim = input_dim
        self.output_dim = output_dim
        
        # Hybrid population
        self.population = []
        
        # Initialize with neural networks
        for _ in range(50):
            net = NeuralConditionAction(input_dim, 20, output_dim)
            self.population.append(net)
        
        # Initialize with random symbolic rules
        for _ in range(50):
            rule = self.create_random_rule()
            self.population.append(rule)
        
        # Components
        self.rule_extractor = RuleExtractor()
        self.hybrid_ga = HybridGeneticAlgorithm()
        self.credit_assignment = HybridBucketBrigade()
        
        # Knowledge base
        self.verified_rules = []  # Rules proven to work
        
    def train(self, environment, generations):
        """
        Main training loop
        """
        for gen in range(generations):
            print(f"\n=== Generation {gen} ===")
            
            # Phase 1: Act in environment
            experiences = self.gather_experiences(environment, episodes=100)
            
            # Phase 2: Credit assignment (Holland's bucket brigade)
            self.assign_credits(experiences)
            
            # Phase 3: Extract rules from successful networks
            if gen % 10 == 0:  # Periodically extract
                self.extract_and_add_rules(experiences)
            
            # Phase 4: Evolve population
            self.population = self.hybrid_ga.evolve_generation(
                self.population, environment
            )
            
            # Phase 5: Verify and consolidate rules
            if gen % 20 == 0:
                self.verify_rules(environment)
            
            # Report
            self.report_status(gen)
    
    def gather_experiences(self, environment, episodes):
        """
        Run episodes and collect experience data
        """
        experiences = []
        
        for episode in range(episodes):
            state = environment.reset()
            episode_data = []
            
            for step in range(100):
                # Hybrid decision making
                action, winner = self.hybrid_classify(state)
                
                # Step environment
                next_state, reward, done = environment.step(action)
                
                # Record
                episode_data.append({
                    'state': state,
                    'action': action,
                    'reward': reward,
                    'winner': winner,
                    'next_state': next_state
                })
                
                if done:
                    break
                    
                state = next_state
            
            experiences.append(episode_data)
        
        return experiences
    
    def hybrid_classify(self, state):
        """
        Both rules and networks compete to classify
        """
        candidates = []
        
        # Neural networks
        for individual in self.population:
            if isinstance(individual, NeuralConditionAction):
                if individual.matches(state):
                    strength, action = individual.evaluate(state)
                    bid = individual.strength * strength.item()
                    candidates.append((bid, individual, action))
        
        # Symbolic rules
        for individual in self.population:
            if isinstance(individual, Rule):
                if individual.matches(state):
                    bid = individual.strength * individual.confidence
                    candidates.append((bid, individual, individual.action))
        
        if not candidates:
            # Random action
            random_individual = random.choice(self.population)
            if isinstance(random_individual, NeuralConditionAction):
                _, action = random_individual.evaluate(state)
            else:
                action = random_individual.action
            return action, random_individual
        
        # Winner
        candidates.sort(reverse=True, key=lambda x: x[0])
        _, winner, action = candidates[0]
        
        return action, winner
    
    def extract_and_add_rules(self, experiences):
        """
        Extract rules from successful neural networks
        """
        # Find successful networks
        successful_networks = [
            ind for ind in self.population
            if isinstance(ind, NeuralConditionAction) and ind.strength > 1.5
        ]
        
        # Extract data for rule extraction
        states = []
        actions = []
        for episode in experiences:
            for step in episode:
                states.append(step['state'])
                actions.append(step['action'])
        
        # Extract rules from each successful network
        for network in successful_networks[:5]:  # Top 5
            rules = self.rule_extractor.extract_rules(
                network, states, actions
            )
            
            # Add to population
            for rule in rules:
                rule.strength = network.strength * 0.5  # Inherit some strength
                self.population.append(rule)
                
            print(f"Extracted {len(rules)} rules from successful network")
    
    def verify_rules(self, environment):
        """
        Test rules on new scenarios and promote verified ones
        """
        rules = [ind for ind in self.population if isinstance(ind, Rule)]
        
        for rule in rules:
            # Test rule
            success_rate = self.test_rule(rule, environment, episodes=10)
            
            if success_rate > 0.8:
                if rule not in self.verified_rules:
                    self.verified_rules.append(rule)
                    print(f"VERIFIED RULE: {rule.to_string()}")
    
    def report_status(self, generation):
        """
        Report current state
        """
        networks = [ind for ind in self.population 
                   if isinstance(ind, NeuralConditionAction)]
        rules = [ind for ind in self.population 
                if isinstance(ind, Rule)]
        
        print(f"Networks: {len(networks)}, Rules: {len(rules)}")
        print(f"Verified rules: {len(self.verified_rules)}")
        
        if self.verified_rules:
            print("\nTop verified rules:")
            for rule in self.verified_rules[:3]:
                print(f"  {rule.to_string()}")

# Create environment
class PatternRecognitionEnvironment:
    def __init__(self):
        self.pattern_type = 0
        
    def reset(self):
        self.pattern_type = random.randint(0, 3)
        return self.generate_pattern()
    
    def generate_pattern(self):
        # Generate patterns with learnable rules
        if self.pattern_type == 0:
            # Rule: IF x[0] > 0.5 AND x[1] > 0.5 THEN class 0
            return np.array([random.uniform(0.5, 1.0), random.uniform(0.5, 1.0)] + 
                          [random.uniform(-1, 1) for _ in range(8)])
        elif self.pattern_type == 1:
            # Rule: IF x[2] < -0.3 THEN class 1
            return np.array([random.uniform(-1, 1), random.uniform(-1, 1),
                          random.uniform(-1, -0.3)] + [random.uniform(-1, 1) for _ in range(7)])
        # ... more patterns
    
    def step(self, action):
        correct = (action == self.pattern_type)
        reward = 1.0 if correct else -0.5
        return self.reset(), reward, True

# Run the system
environment = PatternRecognitionEnvironment()
classifier = NeuroSymbolicEvolutionaryClassifier(input_dim=10, output_dim=4)
classifier.train(environment, generations=100)

# After training, you have:
# 1. Neural networks that classify well
# 2. Extracted symbolic rules that are interpretable
# 3. A hybrid system that uses both

