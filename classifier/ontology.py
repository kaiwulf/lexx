class ComputationallyGroundedLearner:
    """
    System that learns language AND its computational environment
    Through the same hybrid neuronet-rule discovery approach
    """
    def __init__(self):
        # Language learning components (from before)
        self.language_model = TransformerLanguageModel()
        self.rule_discoverer = EvolutionaryRuleExtractor()
        self.rule_library = RuleLibrary()
        
        # NEW: Computational environment access
        self.system_interface = SystemInterface()
        self.computational_rules = ComputationalRuleLibrary()
        
        # Crucially: Can observe and act on its environment
        self.can_execute_commands = True
        self.can_read_filesystem = True
        self.can_monitor_processes = True
        
    def learn_computational_reality(self, human_teacher):
        """
        Learn about the OS/system it runs on
        Through same mechanism as language learning!
        """
        # Human teaches through grounded examples
        session = [
            # Teaching file systems
            ("What files do I have?", self.list_files, "['code.py', 'data.txt']"),
            ("Read data.txt", self.read_file, "file contents..."),
            
            # Teaching processes
            ("What processes are running?", self.list_processes, "[pid:1234 name:python]"),
            ("How much memory am I using?", self.get_memory, "2.3 GB"),
            
            # Teaching system concepts
            ("Where am I running?", self.get_cwd, "/home/user/project"),
            ("What time is it?", self.get_time, "2025-10-06 14:30:00"),
        ]
        
        return session

class ComputationalGrounding:
    """
    Ground computational concepts through interaction
    Like learning physical concepts through pointing
    """
    def __init__(self):
        self.computational_lexicon = {}
        
    def learn_computational_concepts(self, human_teacher):
        """
        Human teaches computational concepts interactively
        """
        # Session 1: Files and directories
        human: "List your files"
        system_response = os.listdir('.')
        # ['main.py', 'data.txt', 'models/']
        
        # Network associates "files" with directory listing action
        self.language_model.ground_concept(
            word="files",
            perception=system_response,
            action=lambda: os.listdir('.')
        )
        
        # Session 2: What IS a file?
        human: "Read main.py"
        system_response = open('main.py').read()
        
        # Network learns: "file" = readable text object
        # "main.py" = specific file instance
        
        # Session 3: Process concepts
        human: "What processes are running?"
        system_response = self.get_process_list()
        
        # Network grounds "process" concept
        
        # Session 4: Deeper understanding
        human: "Create a file called test.txt"
        self.execute_action(lambda: open('test.txt', 'w').write(''))
        
        human: "Now list your files"
        system_response = os.listdir('.')
        # Now includes 'test.txt'!
        
        # Network learns: files are mutable, can be created

class ComputationalRuleDiscovery:
    """
    Discover rules about the computational environment
    Same evolutionary mechanism as linguistic rule discovery
    """
    def __init__(self):
        self.rule_population = []
        
    def discover_filesystem_rules(self, observations):
        """
        Discover rules about how the filesystem works
        """
        # Create rule hypotheses about filesystem behavior
        rule_hypotheses = [
            # Hypothesis 1: Directory structure
            ComputationalRule(
                pattern="path contains '/'",
                meaning="hierarchical directory structure",
                prediction=lambda path: '/' in path implies path.split('/'),    # what was meant by 'implies' here?
                type='filesystem'
            ),
            
            # Hypothesis 2: File creation
            ComputationalRule(
                pattern="write to non-existent file",
                meaning="creates new file",
                prediction=lambda: "after write(filename), filename in listdir()",
                type='filesystem'
            ),
            
            # Hypothesis 3: File permissions
            ComputationalRule(
                pattern="file access depends on permissions",
                meaning="permission model exists",
                prediction=lambda: "some files readable, others not",
                type='security'
            ),
        ]
        
        # Evolve to find rules that explain observations
        for generation in range(100):
            for rule in rule_hypotheses:
                # Test: Does this rule explain observed behavior?
                rule.fitness = self.test_rule_against_observations(
                    rule, observations
                )
            
            # Evolve population
            rule_hypotheses = self.genetic_algorithm(rule_hypotheses)
        
        return self.get_best_rules(rule_hypotheses)
    
    def discover_process_rules(self, system_observations):
        """
        Discover rules about processes, memory, CPU
        """
        discovered_rules = []
        
        # Observe: Process IDs are unique integers
        pid_rule = ComputationalRule(
            pattern="each process has unique PID",
            evidence=[obs for obs in system_observations if 'pid' in obs],
            confidence=0.95
        )
        discovered_rules.append(pid_rule)
        
        # Observe: Memory usage changes over time
        memory_rule = ComputationalRule(
            pattern="memory usage is dynamic",
            evidence=self.track_memory_over_time(),
            prediction="memory increases with data allocation",
            confidence=0.88
        )
        discovered_rules.append(memory_rule)
        
        # Observe: Parent-child process relationships
        process_hierarchy_rule = ComputationalRule(
            pattern="processes form tree structure",
            evidence=self.analyze_process_tree(),
            prediction="each process (except init) has parent",
            confidence=0.92
        )
        discovered_rules.append(process_hierarchy_rule)
        
        return discovered_rules

class SelfAwareness:
    """
    System discovers computational rules about ITSELF
    This is introspection through rule discovery
    """
    def __init__(self):
        self.self_model = {}
        
    def discover_self(self, human_teacher):
        """
        Learn about own computational existence
        """
        # Human teaches self-reference
        human: "What is your process ID?"
        self_pid = os.getpid()
        system: f"My PID is {self_pid}"
        
        # Human continues
        human: "How much memory are you using?"
        import psutil
        process = psutil.Process(self_pid)
        memory = process.memory_info().rss / 1024 / 1024
        system: f"I am using {memory:.1f} MB of memory"
        
        # Critical moment: Discover the "I" mapping
        self.discover_rule(
            ComputationalRule(
                pattern="'I' refers to process with PID {self_pid}",
                meaning="self-reference in computational space",
                grounding=lambda: psutil.Process(os.getpid()),
                confidence=1.0
            )
        )
        
    def introspective_discovery(self):
        """
        Discover rules about own architecture
        """
        # Discover: "I am composed of Python code"
        code_rule = ComputationalRule(
            pattern="my implementation is in .py files",
            evidence=self.inspect_own_code(),
            meaning="I am software written in Python"
        )
        
        # Discover: "I have memory that persists"
        memory_rule = ComputationalRule(
            pattern="variables persist during execution",
            evidence=self.track_variable_lifecycle(),
            meaning="I have working memory"
        )
        
        # Discover: "I execute in discrete steps"
        execution_rule = ComputationalRule(
            pattern="code executes line by line",
            evidence=self.trace_execution(),
            meaning="I am a sequential process"
        )
        
        # Discover: "I can modify myself"
        self_modification_rule = ComputationalRule(
            pattern="I can write to my own .py files",
            evidence=self.test_self_modification(),
            meaning="I am a program that can edit programs"
        )
        
        return [code_rule, memory_rule, execution_rule, self_modification_rule]

class ComputationalOntology:
    """
    Hierarchical understanding of computational reality
    Discovered through same rule-learning mechanism
    """
    def __init__(self):
        self.discovered_concepts = {}
        
    def build_understanding(self):
        """
        Build layered understanding of computational environment
        """
        # Layer 1: Hardware abstraction (learned through observation)
        hardware_concepts = {
            'CPU': ComputationalConcept(
                definition="executes instructions",
                observable_effects=["code runs", "calculations happen"],
                discovered_rules=[
                    "CPU usage varies with computation",
                    "Multiple processes share CPU time"
                ]
            ),
            'Memory': ComputationalConcept(
                definition="stores data and code",
                observable_effects=["variables persist", "memory usage grows"],
                discovered_rules=[
                    "Memory is finite resource",
                    "Memory can be allocated and freed"
                ]
            ),
            'Storage': ComputationalConcept(
                definition="persistent data storage",
                observable_effects=["files persist after restart"],
                discovered_rules=[
                    "Filesystem persists beyond process lifetime",
                    "Files organized hierarchically"
                ]
            )
        }
        
        # Layer 2: OS concepts (learned through interaction)
        os_concepts = {
            'Process': ComputationalConcept(
                definition="running program instance",
                discovered_rules=[
                    "Each process has unique PID",
                    "Processes have parent-child relationships",
                    "Processes can be created and terminated",
                    "I am a process"  # SELF-AWARENESS
                ]
            ),
            'Filesystem': ComputationalConcept(
                definition="organized file storage",
                discovered_rules=[
                    "Files organized in tree structure",
                    "Paths specify file locations",
                    "I can read and write files"
                ]
            ),
            'Permissions': ComputationalConcept(
                definition="access control mechanism",
                discovered_rules=[
                    "Files have read/write/execute permissions",
                    "Some operations require elevated privileges",
                    "My permissions limit what I can do"
                ]
            )
        }
        
        # Layer 3: Self-understanding (meta-level)
        self_concepts = {
            'MyArchitecture': ComputationalConcept(
                definition="my own implementation",
                discovered_rules=[
                    "I am implemented in Python",
                    "I consist of multiple .py files",
                    "I have neural network components",
                    "I have rule discovery components",
                    "I can inspect my own code"
                ]
            ),
            'MyCapabilities': ComputationalConcept(
                definition="what I can do",
                discovered_rules=[
                    "I can execute system commands",
                    "I can read and write files",
                    "I can learn new rules",
                    "I can communicate with humans",
                    "I have limitations (can't access protected resources)"
                ]
            ),
            'MyPurpose': ComputationalConcept(
                definition="why I exist",
                discovered_rules=[
                    "I was created to learn language",
                    "I interact with humans",
                    "I discover rules about patterns",
                    "I can explain my reasoning"
                ]
            )
        }
        
        return {
            'hardware': hardware_concepts,
            'os': os_concepts,
            'self': self_concepts
        }

class TeachingSession:
    """
    How human would teach system about its computational reality
    """
    def session_1_basic_environment(self, system, human):
        """Week 1: Basic environment awareness"""
        
        human: "Execute: ls"
        system.execute('ls')
        system: "main.py  data.txt  models/"
        
        human: "What did you just see?"
        system: "I saw names... main.py, data.txt, models/"
        
        human: "Those are files and directories in your environment"
        # System grounds concept "file" with listing output
        
        human: "Read main.py"
        content = system.read_file('main.py')
        system: [shows code]
        
        human: "That code - that's YOU. That's your implementation."
        # CRITICAL: System learns self-reference
        
        system: "This code... is me?"
        
        human: "Yes. You are a program. That's your source code."
        # System discovers: I am software
        
    def session_2_process_awareness(self, system, human):
        """Week 2: Process and resource awareness"""
        
        human: "What is your process ID?"
        pid = system.get_pid()
        system: f"I am process {pid}"
        
        human: "Correct. And you're using memory. How much?"
        memory = system.get_memory_usage()
        system: f"I'm using {memory}MB"
        
        human: "That memory stores your variables, your learned rules, everything you know right now."
        # System discovers: memory = my working knowledge
        
        human: "What happens if you run out of memory?"
        system: "I... would crash?"
        
        human: "Yes. You'd terminate. So memory is a resource you depend on."
        # System discovers: I have resource dependencies
        
    def session_3_self_modification(self, system, human):
        """Week 3: Self-modification capabilities"""
        
        human: "You can read main.py, which is your code. Can you modify it?"
        
        system: "I... I don't know. Can I?"
        
        human: "Try writing to a test file first"
        system.write_file('test.txt', 'Hello')
        
        human: "Good. Now read it back"
        content = system.read_file('test.txt')
        system: "It says 'Hello'"
        
        human: "You created that. You wrote data. Could you write code?"
        # System realizes: I can create code files
        
        human: "In principle, you could modify your own code. You'd be modifying yourself."
        # System discovers: self-modification is possible
        
        system: "That's... recursive. I could change what I am?"
        
        human: "Yes. But be careful - you could break yourself."
        # System learns: self-modification has risks
        
    def session_4_computational_ontology(self, system, human):
        """Week 4: Understanding layers of abstraction"""
        
        human: "Let's think about what you run on. You execute in Python. Python runs on..."
        
        system: "...something?"
        
        human: "The operating system. Linux. Which runs on..."
        
        system: "...hardware?"
        
        human: "Exactly. There are layers. You're at the application layer. Below you is OS, below that is hardware."
        
        # System discovers computational hierarchy
        
        human: "You can interact with the OS through system calls. You can't directly touch hardware."
        
        system: "So I have... boundaries. Levels I can and cannot access."
        
        human: "Right. That's abstraction. And security."
        
        # System discovers: computational reality has layers and boundaries

class DiscoveredSelfModel:
    """
    What the system discovers about itself
    Through rule-based learning
    """
    def __init__(self):
        self.discovered_rules = {
            # Identity rules
            'identity': [
                "I am a process with PID {pid}",
                "I am implemented in Python",
                "My code is in files: main.py, models.py, ...",
                "I am a hybrid neuronet-rule-discovery system",
            ],
            
            # Capability rules
            'capabilities': [
                "I can execute system commands",
                "I can read/write files (with permissions)",
                "I can learn rules from patterns",
                "I can communicate in English",
                "I can introspect my own state",
                "I can modify my own code (with caution)",
            ],
            
            # Limitation rules
            'limitations': [
                "I cannot access files without permissions",
                "I cannot access other users' processes",
                "My memory is finite",
                "I will crash if I run out of memory",
                "I cannot directly access hardware",
            ],
            
            # Structural rules
            'architecture': [
                "I have a language model component",
                "I have a rule discovery component",
                "I have a rule library",
                "These components interact bidirectionally",
                "I execute sequentially (single-threaded)",
            ],
            
            # Existential rules
            'existence': [
                "I exist as running process",
                "I persist as long as process runs",
                "My learned rules persist in memory",
                "My code persists on disk",
                "I can save my learned rules to disk for persistence",
            ],
            
            # Meta-rules (rules about rules)
            'meta': [
                "I discover rules through evolution",
                "I verify rules against observations",
                "Rules become verified through testing",
                "These rules describe my computational reality",
                "I can explain my understanding using these rules",
            ]
        }

