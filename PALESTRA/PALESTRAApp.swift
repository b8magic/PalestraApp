import SwiftUI
import UniformTypeIdentifiers
import Combine

// MARK: - Palette colori

extension Color {
    // ORDINE PALETTE DA 5: PaletteGreen2, PaletteGreen6, PaletteGreen10, PaletteGreen11, PaletteGreen9
    // #006809, #00900a, #0bb01a, #89ec0f, #a1f21f, /// #0EFF01

    static let PaletteGreen1  = Color(red: 33/255,  green: 48/255,  blue: 32/255)
    static let PaletteGreen1Alt1 = Color(red:   5/255, green:  19/255, blue:   6/255)
    static let PaletteGreen1Alt2 = Color(red:  10/255, green:  31/255, blue:   8/255)
    static let PaletteGreen1Alt3 = Color(red:  15/255, green:  40/255, blue:  15/255)
    static let PaletteGreen1Alt4 = Color(red:  19/255, green:  47/255, blue:  16/255)
    static let PaletteGreen1Alt5 = Color(red:  23/255, green:  57/255, blue:  22/255)
    static let PaletteGreen2  = Color(red:  0/255,  green:104/255,  blue:  9/255)
    static let PaletteGreen3  = Color(red: 63/255,  green: 92/255,  blue: 61/255)
    static let PaletteGreen4  = Color(red:  0/255,  green:144/255,  blue: 10/255)
    static let PaletteGreen4Alt2 = Color(red:   0/255, green: 138/255, blue:  11/255)
    static let PaletteGreen5  = Color(red: 46/255,  green:140/255,  blue: 42/255)
    static let PaletteGreen6  = Color(red: 11/255,  green:176/255,  blue: 26/255)
    static let PaletteGreen6Alt2 = Color(red:   8/255, green: 177/255, blue:  26/255)
    static let PaletteGreen7  = Color(red: 66/255,  green:181/255,  blue: 60/255)
    static let PaletteGreen8  = Color(red:  0/255,  green:239/255,  blue:  1/255)
    static let PaletteGreen9  = Color(red: 14/255,  green:255/255,  blue:  1/255)
    static let PaletteGreen10 = Color(red:137/255,  green:236/255,  blue: 15/255)
    static let PaletteGreen11 = Color(red:161/255,  green:242/255,  blue: 31/255)
}

// MARK: - WaveShape (non usato attualmente)

struct WaveShape: Shape {
    var amplitude: CGFloat = 80
    var yOffset: CGFloat = 0.85

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let midY = rect.height * yOffset
        p.move(to: CGPoint(x: 0, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: midY))
        p.addQuadCurve(
            to: CGPoint(x: rect.width, y: midY),
            control: CGPoint(x: rect.width/2, y: midY + amplitude)
        )
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.closeSubpath()
        return p
    }
}

// MARK: - FluidBackground

struct FluidBackground: View {
    var body: some View {
        GeometryReader { _ in
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.PaletteGreen1Alt3,
                    Color.PaletteGreen2,
                    Color.PaletteGreen6,
                    Color.PaletteGreen8,
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            .padding(.bottom, -300)
        }
    }
}

// MARK: - VisioneIngressoView

struct VisioneIngressoView: View {
    @EnvironmentObject var data: AppData

    @State private var showExport        = false
    @State private var showImport        = false
    @State private var showImportConfirm = false
    @State private var importResultMessage = ""
    @State private var showImportResultAlert = false
    @State private var importURL: URL?
    @State private var showTodayLog = false

    var body: some View {
        NavigationStack {
            ZStack {
                FluidBackground()
                VStack(alignment: .leading, spacing: 24) {

                    // Titolo + calendario
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PALESTRA")
                                .font(.system(size: 40, weight: .heavy))
                                .foregroundColor(.white)
                            Text("Sempre in forma!")
                                .font(.title2.weight(.medium))
                                .foregroundColor(.white)
                                .bold()
                        }
                        Spacer()
                        NavigationLink {
                            ContentView(initialSelection: .calendar)
                                .environmentObject(data)
                                .withPalestraButton()
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            Circle()
                                .fill(Color.PaletteGreen10)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Image(systemName: "calendar")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.PaletteGreen2)
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    // SCHEDA ATTIVA
                    Menu {
                        ForEach(data.plans) { plan in
                            Button { data.activePlanId = plan.id } label: {
                                HStack {
                                    Text(plan.name)
                                    Spacer()
                                    if plan.id == data.activePlanId {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(
                            data.plans
                                .first { $0.id == data.activePlanId }?
                                .name
                            ?? "Seleziona"
                        )
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.PaletteGreen1Alt5)
                        .cornerRadius(16)
                    }

                    // Preview AREA PRINCIPALE
                    NavigationLink {
                        ContentView(initialSelection: .main)
                            .environmentObject(data)
                            .withPalestraButton()
                    } label: {
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer()
                            (data.suggestNextSuggestions().first ?? Text("Nessuna scheda attiva"))
                                .foregroundColor(.white)

                            let lastThree = Array(
                                data.workoutLogs.sorted { $0.date > $1.date }.prefix(3)
                            ).reversed()
                            if !lastThree.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Spacer()
                                    Text("ALLENAMENTI:").bold()
                                    ForEach(lastThree, id: \.id) { e in
                                        Text(e.date.formatted("dd/MM/yyyy") + ": " +
                                             (e.isLongPause ? "Pausa" : e.muscleGroups.map(\.name).joined(separator: " + ")))
                                    }
                                }
                                .font(.headline).foregroundColor(.white)
                            }

                            Spacer(minLength: 0)

                            HStack {
                                Spacer()
                                NavigationLink {
                                    ContentView(initialSelection: .construction)
                                        .environmentObject(data)
                                        .withPalestraButton()
                                } label: {
                                    Circle()
                                        .fill(Color.PaletteGreen10)
                                        .frame(width: 70, height: 70)
                                        .overlay(
                                            Image(systemName: "dumbbell")
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(.PaletteGreen2)
                                        )
                                        .contentShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 280, alignment: .leading)
                        .background(Color.white.opacity(0.10))
                        .cornerRadius(24)
                    }
                    .buttonStyle(.plain)

                    // Nuovo riquadro "Cosa hai allenato oggi?"
                    Button {
                        showTodayLog = true
                    } label: {
                        VStack {
                            Spacer()
                            Text("Cosa hai allenato oggi?")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 70)
                        .background(Color.white.opacity(0.10))
                        .cornerRadius(24)
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showTodayLog) {
                        DayLogView(date: Date()).environmentObject(data)
                    }

                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 100)
            }
            .fileExporter(
                isPresented: $showExport,
                document: BackupDocument(data: makeBackupData()),
                contentType: .json,
                defaultFilename: "PalestraBackup"
            ) { _ in }
            .fileImporter(
                isPresented: $showImport,
                allowedContentTypes: [.json]
            ) { result in
                if case .success(let url) = result {
                    importURL = url
                    showImportConfirm = true
                }
            }
            .sheet(isPresented: $showImportConfirm) {
                ImportConfirmationView(
                    message: "Sei sicuro di voler sovrascrivere tutti i dati esistenti?",
                    importAction: {
                        showImportConfirm = false
                        performImport(from: importURL)
                    },
                    cancelAction: {
                        showImportConfirm = false
                    }
                )
            }
        }
        .alert(importResultMessage, isPresented: $showImportResultAlert) {
            Button("...ed ora vado in pale!", role: .cancel) { }
        }
    }

    private func makeBackupData() -> Data {
        let backup = Backup(
            plans: data.plans,
            activePlanId: data.activePlanId,
            workoutLogs: data.workoutLogs,
            historyStartMonth: data.historyStartMonth
        )
        return (try? JSONEncoder().encode(backup)) ?? Data()
    }

    private func performImport(from url: URL?) {
        guard let url = url else {
            importResultMessage = "⚠️ URL del file non valido."
            showImportResultAlert = true
            return
        }
        let didStart = url.startAccessingSecurityScopedResource()
        defer {
            if didStart { url.stopAccessingSecurityScopedResource() }
        }
        do {
            let rawData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .deferredToDate
            let backup = try decoder.decode(Backup.self, from: rawData)
            DispatchQueue.main.async {
                data.plans             = backup.plans
                data.activePlanId      = backup.activePlanId
                data.workoutLogs       = backup.workoutLogs
                data.historyStartMonth = backup.historyStartMonth
                importResultMessage = "Salvataggio importato con successo..."
                showImportResultAlert = true
            }
        } catch {
            importResultMessage = "❌ Errore durante l’importazione:\n\(error.localizedDescription)"
            showImportResultAlert = true
        }
    }
}

// MARK: - Modelli di backup

struct Backup: Codable {
    var plans: [TrainingPlan]
    var activePlanId: UUID?
    var workoutLogs: [WorkoutLogEntry]
    var historyStartMonth: Date?
}

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.json]
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws {
        guard let fileData = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        data = fileData
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        .init(regularFileWithContents: data)
    }
}

// MARK: - Modelli core

struct TrainingPlan: Identifiable, Codable {
    var id: UUID
    var name: String
    var length: Int
    var muscleGroups: [MuscleGroup]
    var days: [DayPlan]
    var startAfterLongPauseDayId: UUID?
    var minLongPauseDays: Int
    var strictMode: Bool
    var showDetailsColumn: Bool
}

struct MuscleGroup: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
}

struct DayPlan: Identifiable, Codable {
    var id: UUID
    var muscleGroups: [MuscleGroup]
    var title: String
    var description: String
}

struct WorkoutLogEntry: Identifiable, Codable {
    var id: UUID
    var date: Date
    var muscleGroups: [MuscleGroup]
    var isLongPause: Bool
}

// MARK: - AppData

class AppData: ObservableObject {
    @Published var plans: [TrainingPlan] = []
    @Published var activePlanId: UUID?
    @Published var workoutLogs: [WorkoutLogEntry] = []
    @Published var historyStartMonth: Date?

    // For skipped pause alert
    @Published var skippedPauseDates: [Date] = []

    private var saveCancellable: AnyCancellable?

    init() {
        load()
        if plans.isEmpty {
            addDefaultPlan()
        } else if activePlanId == nil {
            activePlanId = plans.first?.id
        }
        saveCancellable = Publishers
            .CombineLatest4($plans, $activePlanId, $workoutLogs, $historyStartMonth)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _,_,_,_ in self?.save() }
    }

    var activePlan: TrainingPlan? {
        get { activePlanId.flatMap { id in plans.first { $0.id == id } } }
        set {
            guard let p = newValue,
                  let idx = plans.firstIndex(where: { $0.id == p.id })
            else { return }
            plans[idx] = p
        }
    }

    func addDefaultPlan() {
        let defaultGroups = ["Spalle","Petto","Schiena","Bicipiti","Tricipiti","Gambe"].map {
            MuscleGroup(id: UUID(), name: $0)
        }
        let p = TrainingPlan(
            id: UUID(),
            name: "Nuova scheda",
            length: 1,
            muscleGroups: defaultGroups,
            days: [
                DayPlan(id: UUID(), muscleGroups: [], title: "", description: "")
            ],
            startAfterLongPauseDayId: nil,
            minLongPauseDays: 10,
            strictMode: false,
            showDetailsColumn: false
        )
        plans.append(p)
        activePlanId = p.id
    }

    private func docs(_ name: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(name)
    }

    func save() {
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
        if let d = try? enc.encode(plans) { try? d.write(to: docs("plans.json")) }
        if let id = activePlanId {
            UserDefaults.standard.set(id.uuidString, forKey: "activePlanId")
        }
        if let d = try? enc.encode(workoutLogs) {
            try? d.write(to: docs("logs.json"))
        }
        let fmt = ISO8601DateFormatter()
        if let h = historyStartMonth {
            UserDefaults.standard.set(fmt.string(from: h), forKey: "historyStartMonth")
        } else {
            UserDefaults.standard.removeObject(forKey: "historyStartMonth")
        }
    }

    func load() {
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        if let d = try? Data(contentsOf: docs("plans.json")),
           let arr = try? dec.decode([TrainingPlan].self, from: d) {
            plans = arr
        }
        if let s = UserDefaults.standard.string(forKey: "activePlanId"),
           let id = UUID(uuidString: s),
           plans.contains(where: { $0.id == id }) {
            activePlanId = id
        }
        if let d = try? Data(contentsOf: docs("logs.json")),
           let arr = try? dec.decode([WorkoutLogEntry].self, from: d) {
            workoutLogs = arr
        }
        let fmt = ISO8601DateFormatter()
        if let hs = UserDefaults.standard.string(forKey: "historyStartMonth"),
           let dt = fmt.date(from: hs) {
            historyStartMonth = dt
        }
    }

    // MARK: - Suggestion Algorithm
    func suggestNextSuggestions() -> [Text] {
        // Questa funzione calcola i suggerimenti per il prossimo allenamento (o pause)
        // in base alla scheda attiva e ai log esistenti.
        // COMMENTI: NON_RIMUOVERE_COMMENTI – utili per futuri sviluppatori e LLM.

        // Se non c’è una scheda attiva
        guard let plan = activePlan else {
            return [ Text("Nessuna scheda attiva. Vai alla Costruzione schede.") ]
        }

        // 8) Se c'è una sola scheda e tutti i giorni sono vuoti → invito a crearne una
        if plans.count == 1 && plan.days.allSatisfy({ $0.muscleGroups.isEmpty }) {
            return [ Text("Suggerimenti: tocca il manubrio per creare una scheda di allenamento") ]
        }

        let cycle = plan.days
        let n = cycle.count
        let logs = workoutLogs.sorted { $0.date < $1.date }
        let today = Calendar.current.startOfDay(for: Date())
        let usedToday = logs.contains { Calendar.current.isDate($0.date, inSameDayAs: today) }
        let label = usedToday ? "Domani" : "Oggi"

        // 6) Conta quante pause consecutive ha già fatto l'utente
        var userPauseCount = 0
        for entry in logs.reversed() {
            if entry.isLongPause {
                userPauseCount += 1
            } else {
                break
            }
        }

        // Trova gli ultimi allenamenti (non pause) entro la soglia di lunga pausa
        let cutoff = Calendar.current.date(byAdding: .day, value: -plan.minLongPauseDays, to: today)!
        let recentNonPauseIndices = logs.indices
            .filter { logs[$0].date >= cutoff && !logs[$0].isLongPause }
            .reversed()

        // 2) e 3) Gestione di titoli fatti solo di spazi/tab tratto come vuoto
        for i0 in recentNonPauseIndices {
            let strict = plan.strictMode
            var bestStarts: [Int] = []
            var maxLen = 0

            // Matching della sequenza di allenamenti
            for j in 0..<n {
                var len = 0, offset = 0, nonPauseCount = 0
                while i0 - offset >= 0 && nonPauseCount < plan.minLongPauseDays {
                    let logEntry = logs[i0 - offset]
                    let dayPlan  = cycle[(j - offset % n + n) % n]

                    if logEntry.isLongPause {
                        if dayPlan.muscleGroups.isEmpty {
                            len += 1; offset += 1; continue
                        } else { break }
                    }
                    if match(log: logEntry, day: dayPlan, strict: strict) {
                        len += 1; nonPauseCount += 1; offset += 1
                    } else { break }
                }
                if len > 0 {
                    if len > maxLen {
                        maxLen = len; bestStarts = [j]
                    } else if len == maxLen {
                        bestStarts.append(j)
                    }
                }
            }

            if maxLen > 0 {
                return bestStarts.enumerated().map { (index, start) in
                    let nextIndex = (start + 1) % n
                    let nextPlan  = cycle[nextIndex]
                    let prefix    = index == 0 ? "\(label) devi fare:" : "Oppure:"

                    let trimmedTitle = nextPlan.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    let hasTitle      = !trimmedTitle.isEmpty
                    let desc          = nextPlan.description.trimmingCharacters(in: .whitespacesAndNewlines)

                    // 5) Se il giorno suggerito è vuoto → pausa
                    if nextPlan.muscleGroups.isEmpty {
                        // Conta quante pause consecutive richiede la scheda da qui
                        var planPauseDays = 0
                        var idx = nextIndex
                        while cycle[idx].muscleGroups.isEmpty {
                            planPauseDays += 1
                            idx = (idx + 1) % n
                        }
                        // 6) Se l'utente non ha ancora fatto tutte le pause richieste
                        if userPauseCount < planPauseDays {
                            // 2) Sostituisce il trattino con "Pausa"
                            return Text("\(prefix) ") + Text("Pausa").bold()
                        } else {
                            // Ha già fatto abbastanza pause → suggerisce il giorno successivo non-pausa
                            let skipIndex = (nextIndex + planPauseDays) % n
                            let actualPlan = cycle[skipIndex]
                            let actualTitle = actualPlan.title.trimmingCharacters(in: .whitespacesAndNewlines)
                            let hasActualTitle = !actualTitle.isEmpty
                            let groups = actualPlan.muscleGroups.map(\.name).joined(separator: " + ")
                            let titlePart: Text = {
                                if hasActualTitle {
                                    return Text("\(actualTitle) (\(groups))").bold()
                                } else {
                                    return Text(groups).bold()
                                }
                            }()
                            var t = Text("\(prefix) ") + titlePart
                            if !desc.isEmpty {
                                t = t + Text("\n\(desc)").italic()
                            }
                            return t
                        }
                    }

                    // 4) Giorni di allenamento normali
                    let groups = nextPlan.muscleGroups.map(\.name).joined(separator: " + ")
                    let titlePart: Text = {
                        if hasTitle {
                            return Text("\(trimmedTitle) (\(groups))").bold()
                        } else {
                            return Text(groups).bold()
                        }
                    }()
                    var t = Text("\(prefix) ") + titlePart
                    if !desc.isEmpty {
                        t = t + Text("\n\(desc)").italic()
                    }
                    return t
                }
            }
        }

        // Fallback dopo lunga pausa impostata (comportamento originale)
        if let startId = plan.startAfterLongPauseDayId,
           let idx = cycle.firstIndex(where: { $0.id == startId }) {
            let d       = cycle[idx]
            let groups  = d.muscleGroups.map(\.name).joined(separator: " + ")
            let trimmed = d.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let hasT    = !trimmed.isEmpty
            let desc    = d.description.trimmingCharacters(in: .whitespacesAndNewlines)

            let titleText: Text = {
                if hasT {
                    return Text("\(trimmed) (\(groups))").bold()
                } else {
                    // 2) Se vuoto → pausa
                    return Text(groups.isEmpty ? "Pausa" : groups).bold()
                }
            }()
            var t: Text
            if groups.isEmpty && trimmed.isEmpty {
                t = Text("Suggerimenti: cambia il giorno di inizio scheda nelle impostazioni e verifica di aver seguito la scheda correttamente")
            } else {
                t = Text("\(label) devi fare: ") + titleText + Text(" dopo lunga pausa")
                if !desc.isEmpty {
                    t = t + Text("\n\(desc)").italic()
                }
            }
            return [t]
        }

        // Nessuna configurazione iniziale
        return [ Text("Suggerimenti: seleziona un giorno di inizio scheda nelle impostazioni (o verifica di aver seguito la scheda correttamente)") ]
    }
    // NON_RIMUOVERE_COMMENTI – fondamentali per futuri sviluppatori e modelli LLM successors.
    
    
    // MARK: func match(log
    
    private func match(log: WorkoutLogEntry, day: DayPlan, strict: Bool) -> Bool {
        let logSet = Set(log.muscleGroups.map(\.name))
        let daySet = Set(day.muscleGroups.map(\.name))
        if daySet.isEmpty { return logSet.isEmpty }
        return strict ? logSet.isSubset(of: daySet) : !logSet.isDisjoint(with: daySet)
    }
    
    
    // MARK: - Long Pause & Logging

    /// Inserts long pause and returns any dates that were skipped because they had workouts.
    func insertLongPause(from start: Date, to end: Date) -> [Date] {
        let cal = Calendar.current
        var d = cal.startOfDay(for: start)
        let last = cal.startOfDay(for: end)
        var skipped: [Date] = []

        while d <= last {
            if let i = workoutLogs.firstIndex(where: { cal.isDate($0.date, inSameDayAs: d) }) {
                if workoutLogs[i].isLongPause {
                    // already pause, no change
                } else {
                    // skip existing workout
                    skipped.append(d)
                }
            } else {
                workoutLogs.append(
                    WorkoutLogEntry(id: UUID(), date: d, muscleGroups: [], isLongPause: true)
                )
            }
            d = cal.date(byAdding: .day, value: 1, to: d)!
        }

        // Save skipped dates to publish
        skippedPauseDates = skipped
        return skipped
    }

    func saveWorkout(on date: Date, groups: [MuscleGroup]) {
        let cal = Calendar.current
        if let i = workoutLogs.firstIndex(where: { cal.isDate($0.date, inSameDayAs: date) }) {
            workoutLogs[i].muscleGroups = groups
            workoutLogs[i].isLongPause = groups.isEmpty
        } else {
            workoutLogs.append(
                WorkoutLogEntry(id: UUID(), date: date, muscleGroups: groups, isLongPause: groups.isEmpty)
            )
        }
    }
}

// MARK: - Date Helpers

extension Date {
    func formatted(_ fmt: String = "EEEE dd/MM/yy") -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = fmt
        return f.string(from: self)
    }
    var startOfMonth: Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: self)
        )!
    }
}

// MARK: - Entry point

@main
struct PalestraApp: App {
    @StateObject private var data = AppData()
    var body: some Scene {
        WindowGroup {
            VisioneIngressoView()
                .environmentObject(data)
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @EnvironmentObject var data: AppData
    enum Tab { case main, construction, calendar }
    @State private var selection: Tab

    init(initialSelection: Tab = .main) {
        _selection = State(initialValue: initialSelection)
    }

    var body: some View {
        TabView(selection: $selection) {
            MainView()
                .tabItem { Label("Area principale", systemImage: "house") }
                .tag(Tab.main)
            ConstructionView()
                .tabItem { Label("Costruzione schede", systemImage: "square.grid.2x2") }
                .tag(Tab.construction)
            CalendarView()
                .tabItem { Label("Calendario allenamenti", systemImage: "calendar") }
                .tag(Tab.calendar)
        }
        .environmentObject(data)
    }
}

// MARK: - MainView

struct MainView: View {
    @EnvironmentObject var data: AppData

    @State private var showExport = false
    @State private var showImport = false
    @State private var showImportConfirm = false
    @State private var importResultMessage = ""
    @State private var showImportResultAlert = false
    @State private var importURL: URL?

    var body: some View {
        let lastTen = Array(
            data.workoutLogs
                .sorted(by: { $0.date > $1.date })
                .prefix(10)
        ).reversed()

        let history = computeFullHistory()
        // Count full days (non time-jump lines)
        let fullDaysCount = history.filter { !$0.hasPrefix("->SALTO TEMPORALE") }.count

        ScrollView {
            VStack(alignment: .leading) {
                // Sezione 1: Scheda attiva + suggerimenti
                VStack(alignment: .leading, spacing: 16) {
                    Menu {
                        ForEach(data.plans) { plan in
                            Button {
                                data.activePlanId = plan.id
                            } label: {
                                HStack {
                                    Text(plan.name)
                                    Spacer()
                                    if plan.id == data.activePlanId {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text("Scheda")
                                .font(.caption)
                                .foregroundColor(.gray)
                            HStack(spacing: 4) {
                                Text(
                                    data.plans
                                        .first { $0.id == data.activePlanId }?
                                        .name
                                    ?? "Seleziona"
                                )
                                Image(systemName: "chevron.down")
                            }
                            .font(.headline).bold()
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(16)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Spacer()

                    let suggestions: [Text] = data.suggestNextSuggestions()
                    ForEach(Array(suggestions.enumerated()), id: \.0) { _, suggestion in
                        suggestion
                            .font(.body)
                    }
                }
                .padding(.bottom, 32)

                // Sezione 2: ALLENAMENTI
                if !lastTen.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ALLENAMENTI:").bold()
                        ForEach(lastTen, id: \.id) { e in
                            HStack {
                                Text(e.date.formatted("dd/MM/yyyy") + ":")
                                Text(e.isLongPause
                                     ? "-"
                                     : e.muscleGroups.map(\.name).joined(separator: " + ")
                                )
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }

                // Sezione 3: SCHEDA
                VStack(alignment: .leading, spacing: 8) {
                    Text("SCHEDA:").bold()
                    if let plan = data.activePlan {
                        ForEach(plan.days) { d in
                            let blocks = d.muscleGroups.isEmpty
                                ? "-"
                                : d.muscleGroups.map(\.name).joined(separator: " + ")
                            if d.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(blocks)
                            } else {
                                Text("\(d.title): \(blocks)")
                            }
                        }
                    }
                }
                .padding(.bottom, 32)

                // Reorder history and backup based on length >50
                if fullDaysCount > 50 {
                    Spacer().padding(100)
                    backupButtons
                    if !history.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("STORICO ALLENAMENTI:").bold()
                            ForEach(history, id: \.self) { line in
                                Text(line)
                            }
                        }
                        .padding(.bottom, 32)
                    }
                } else {
                    if !history.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("STORICO ALLENAMENTI:").bold()
                            ForEach(history, id: \.self) { line in
                                Text(line)
                            }
                        }
                        .padding(.bottom, 32)
                    }
                    Spacer().padding(100)
                    backupButtons
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .fileExporter(
            isPresented: $showExport,
            document: BackupDocument(data: makeBackupData()),
            contentType: .json,
            defaultFilename: "PalestraBackup"
        ) { _ in }
        .fileImporter(
            isPresented: $showImport,
            allowedContentTypes: [.json]
        ) { result in
            if case .success(let url) = result {
                importURL = url
                showImportConfirm = true
            }
        }
        .sheet(isPresented: $showImportConfirm) {
            ImportConfirmationView(
                message: "Sei sicuro di voler sovrascrivere tutti i dati esistenti con il backup selezionato?",
                importAction: {
                    showImportConfirm = false
                    performImport(from: importURL)
                },
                cancelAction: {
                    showImportConfirm = false
                }
            )
        }
        .alert(importResultMessage, isPresented: $showImportResultAlert) {
            Button("...ed ora vado in pale!", role: .cancel) { }
        }
    }

    // MARK: - Backup Buttons View
    private var backupButtons: some View {
        HStack(spacing: 16) {
            Button(action: { showExport = true }) {
                Text("Esporta salvataggio")
                    .font(.title3)
                    .foregroundColor(.purple)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.purple, lineWidth: 2)
                    )
            }.contentShape(Rectangle())
            Button(action: { showImport = true }) {
                Text("Importa salvataggio")
                    .font(.title3)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 2)
                    )
            }.contentShape(Rectangle())
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
    }

    private func computeFullHistory() -> [String] {
        let sorted = data.workoutLogs.sorted(by: { $0.date < $1.date })
        var result: [String] = []
        var i = 0
        let cal = Calendar.current
        while i < sorted.count {
            let e = sorted[i]
            if e.isLongPause {
                var j = i
                while j < sorted.count && sorted[j].isLongPause { j += 1 }
                let len = j - i
                if len > 15 {
                    let s = sorted[i].date.formatted("dd/MM/yyyy")
                    let t = sorted[j-1].date.formatted("dd/MM/yyyy")
                    result.append("->SALTO TEMPORALE dal \(s) al \(t)")
                } else {
                    for k in i..<j {
                        result.append("\(sorted[k].date.formatted("dd/MM/yyyy")): -")
                    }
                }
                i = j
            } else {
                let groups = sorted[i].muscleGroups.map(\.name).joined(separator: " + ")
                result.append("\(sorted[i].date.formatted("dd/MM/yyyy")): \(groups)")
                i += 1
            }
        }
        return result
    }

    private func makeBackupData() -> Data {
        let backup = Backup(
            plans: data.plans,
            activePlanId: data.activePlanId,
            workoutLogs: data.workoutLogs,
            historyStartMonth: data.historyStartMonth
        )
        return (try? JSONEncoder().encode(backup)) ?? Data()
    }

    private func performImport(from url: URL?) {
        guard let url = url else {
            importResultMessage = "⚠️ URL del file non valido."
            showImportResultAlert = true
            return
        }
        let didStart = url.startAccessingSecurityScopedResource()
        defer {
            if didStart { url.stopAccessingSecurityScopedResource() }
        }
        do {
            let rawData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .deferredToDate
            let backup = try decoder.decode(Backup.self, from: rawData)
            DispatchQueue.main.async {
                data.plans             = backup.plans
                data.activePlanId      = backup.activePlanId
                data.workoutLogs       = backup.workoutLogs
                data.historyStartMonth = backup.historyStartMonth
                importResultMessage = "Salvataggio importato con successo..."
                showImportResultAlert = true
            }
        } catch {
            importResultMessage = "❌ Errore durante l’importazione:\n\(error.localizedDescription)"
            showImportResultAlert = true
        }
    }
}

// MARK: - ConstructionView

struct ConstructionView: View {
    @EnvironmentObject var data: AppData
    @State private var showAddGroup = false
    @State private var newGroupName = ""
    @State private var showSettings = false
    @State private var pendingLength = 1
    @State private var confirmRemove = false
    @State private var confirmDeleteIndices: IndexSet?
    @State private var showDeleteGroupConfirm = false

    var body: some View {
        Group {
            if data.activePlan == nil {
                Text("Nessuna scheda attiva")
                    .onAppear { data.addDefaultPlan() }
            } else {
                mainContent
                    .onChange(of: data.activePlanId) { _, _ in
                        pendingLength = data.activePlan?.length ?? 1
                    }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Spacer().frame(height: 0)
                bottomBar
            }
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showAddGroup) { addGroupSheet }
        .sheet(isPresented: $showSettings) {
            SettingsView(pendingLength: $pendingLength)
                .environmentObject(data)
        }
        .alert("Rimuovere i giorni extra?", isPresented: $confirmRemove) {
            Button("Rimuovi", role: .destructive) {
                adjustPlanLength(to: pendingLength, force: true)
            }
            Button("Annulla", role: .cancel) {
                pendingLength = data.activePlan!.length
            }
        }
        .onChange(of: pendingLength) { _, newVal in
            adjustPlanLength(to: newVal, force: false)
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        let plan = data.activePlan!
        return VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 6) {
                // Colonna Gruppi Muscolari
                VStack {
                    Text("Gruppi muscolari").bold()
                    ScrollView {
                        ForEach(plan.muscleGroups) { g in
                            Text(g.name)
                                .frame(maxWidth: 100)
                                .padding(6)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.blue.opacity(0.3))
                                        .frame(width: 112)
                                )
                                .contentShape(RoundedRectangle(cornerRadius: 16))
                                .onDrag {
                                    NSItemProvider(object: g.id.uuidString as NSString)
                                } preview: {
                                    Text(g.name)
                                        .frame(maxWidth: 100)
                                        .padding(6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.blue.opacity(0.3))
                                                .frame(width: 112)
                                        )
                                }
                        }
                    }
                }
                .frame(width: 140)

                // Scheda + Dettagli
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 0) {
                        if plan.showDetailsColumn {
                            VStack(alignment: .leading) {
                                Text("Descrizioni").bold().padding(.leading, 8)
                                ScrollView {
                                    ForEach(plan.days) { day in
                                        let idx = plan.days.firstIndex { $0.id == day.id }!
                                        DayDetailCell(dayIndex: idx)
                                            .environmentObject(data)
                                            .frame(minWidth: 80)
                                    }
                                }
                            }
                        }
                        VStack {
                            Text("Scheda").bold().multilineTextAlignment(.center)
                            ScrollView {
                                ForEach(plan.days) { day in
                                    let idx = plan.days.firstIndex { $0.id == day.id }!
                                    ConstructionDayCell(dayIndex: idx)
                                        .environmentObject(data)
                                }
                            }
                        }
                        .padding(.leading, 12)
                    }
                }
                .padding(.trailing, 10)
            }
        }
        .padding(.top, 30)
        .padding(.leading, 10)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        let plan = data.activePlan!
        return HStack(spacing: 2) {
            // Sinistra: Aggiungi Gruppo
            VStack {
                Spacer()
                Button {
                    showAddGroup = true
                } label: {
                    Image("croceMuscoli")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green, lineWidth: 2)
                        )
                }
                .frame(width: 145, height: 145)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 4)

            // Centro: Mostra/Nascondi Dettagli + Selettore Scheda
            VStack(spacing: 2) {
                Button {
                    data.activePlan?.showDetailsColumn.toggle()
                } label: {
                    Text("Mostra/Nascondi\nDescrizioni")
                        .font(.subheadline).bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(width: 108, height: 60)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 6)

                Spacer(minLength: 0)

                Menu {
                    ForEach(data.plans) { p in
                        Button {
                            data.activePlanId = p.id
                        } label: {
                            HStack {
                                Text(p.name)
                                Spacer()
                                if p.id == data.activePlanId {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text("Scheda")
                            .font(.caption).bold()
                            .foregroundColor(.gray)
                        HStack(spacing: 1) {
                            Text(plan.name)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .font(.caption).bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 3)
                        .frame(width: 108, height: 80)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                }
            }
            .frame(width: 112)
            .padding(.leading, 16)
            .padding(.top, 4)

            // Destra: Crea, Duplica, Impostazioni
            VStack(spacing: 6) {
                Button {
                    data.addDefaultPlan()
                } label: {
                    Text("Crea nuova\nscheda")
                        .font(.subheadline).bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(width: 108, height: 46)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())

                Button {
                    duplicateCurrentPlan()
                } label: {
                    Text("Duplica\nscheda")
                        .font(.subheadline).bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(width: 108, height: 46)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer(minLength: 0)

                Button("Impostazioni") {
                    pendingLength = plan.length
                    showSettings = true
                }
                .frame(width: 108, height: 46)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 144)
        .padding(.horizontal, 10)
        .padding(.bottom, 20)
        .padding(.top, 10)
    }

    // MARK: - Add Group Sheet

    private var addGroupSheet: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Nuovo Gruppo Muscolare", text: $newGroupName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Aggiungi") {
                        guard !newGroupName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        var p = data.activePlan!
                        p.muscleGroups.append(
                            MuscleGroup(id: UUID(), name: newGroupName.trimmingCharacters(in: .whitespaces))
                        )
                        data.activePlan = p
                        newGroupName = ""
                    }
                    .disabled(newGroupName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()

                List {
                    ForEach(data.activePlan?.muscleGroups ?? []) { g in
                        Text(g.name)
                            .swipeActions(edge: .trailing) {
                                Button("Elimina", role: .destructive) {
                                    if let idx = data.activePlan?.muscleGroups.firstIndex(where: { $0.id == g.id }) {
                                        confirmDeleteIndices = IndexSet([idx])
                                        showDeleteGroupConfirm = true
                                    }
                                }
                            }
                    }
                    .onMove { indices, newOffset in
                        var p = data.activePlan!
                        p.muscleGroups.move(fromOffsets: indices, toOffset: newOffset)
                        data.activePlan = p
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Mattoncini", displayMode: .inline)
            .alert("Confermare eliminazione?", isPresented: $showDeleteGroupConfirm) {
                Button("Elimina", role: .destructive) {
                    if let indices = confirmDeleteIndices {
                        var p = data.activePlan!
                        p.muscleGroups.remove(atOffsets: indices)
                        data.activePlan = p
                    }
                    confirmDeleteIndices = nil
                }
                Button("Annulla", role: .cancel) {
                    confirmDeleteIndices = nil
                }
            }
        }
    }

    // MARK: - Helpers

    private func duplicateCurrentPlan() {
        guard let old = data.activePlan else { return }
        let newGroups = old.muscleGroups.map {
            MuscleGroup(id: UUID(), name: $0.name)
        }
        let mapOldToNew = Dictionary(uniqueKeysWithValues:
            zip(old.muscleGroups.map(\.id), newGroups)
        )
        let newDays = old.days.map { day in
            let cloned = day.muscleGroups.compactMap { mapOldToNew[$0.id] }
            return DayPlan(id: UUID(),
                           muscleGroups: cloned,
                           title: day.title,
                           description: day.description)
        }
        var newStart: UUID? = nil
        if let oldStart = old.startAfterLongPauseDayId,
           let idx = old.days.firstIndex(where: { $0.id == oldStart }) {
            newStart = newDays[idx].id
        }
        let newPlan = TrainingPlan(
            id: UUID(),
            name: old.name + " - copia",
            length: old.length,
            muscleGroups: newGroups,
            days: newDays,
            startAfterLongPauseDayId: newStart,
            minLongPauseDays: old.minLongPauseDays,
            strictMode: old.strictMode,
            showDetailsColumn: old.showDetailsColumn
        )
        data.plans.append(newPlan)
        data.activePlanId = newPlan.id
    }

    private func adjustPlanLength(to newLen: Int, force: Bool) {
        var p = data.activePlan!
        if newLen < p.length {
            let slice = p.days[newLen..<p.length]
            let hasData = slice.contains {
                !$0.muscleGroups.isEmpty ||
                !$0.title.trimmingCharacters(in: .whitespaces).isEmpty ||
                !$0.description.trimmingCharacters(in: .whitespaces).isEmpty
            }
            if hasData && !force {
                confirmRemove = true
                return
            }
            p.days = Array(p.days.prefix(newLen))
        } else if newLen > p.length {
            p.days.append(contentsOf:
                (p.length..<newLen).map { _ in
                    DayPlan(id: UUID(), muscleGroups: [], title: "", description: "")
                }
            )
        }
        p.length = newLen
        data.activePlan = p
    }
}

// MARK: - ConstructionDayCell

struct ConstructionDayCell: View {
    @EnvironmentObject var data: AppData
    let dayIndex: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
                .frame(width: 240, height: 60)

            VStack(spacing: 4) {
                if let plan = data.activePlan,
                   dayIndex < plan.days.count {
                    let title = plan.days[dayIndex].title.trimmingCharacters(in: .whitespacesAndNewlines)
                    Text(title.isEmpty ? "Giorno \(dayIndex + 1)" : title)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)

                    HStack {
                        Spacer(minLength: 8)
                        ForEach(plan.days[dayIndex].muscleGroups) { mg in
                            Text(mg.name)
                                .font(.footnote)
                                .padding(4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.blue.opacity(0.3))
                                )
                                .onTapGesture {
                                    var p = plan
                                    p.days[dayIndex].muscleGroups
                                        .removeAll { $0.id == mg.id }
                                    data.activePlan = p
                                }
                        }
                        Spacer(minLength: 8)
                    }
                    .padding(.bottom, 4)
                } else {
                    Text("Giorno \(dayIndex + 1)")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                    Spacer()
                }
            }
            .frame(width: 240, height: 60)
        }
        .contentShape(Rectangle())
        .onDrop(of: [UTType.text], delegate: DropHandler(dayIndex: dayIndex, data: data))
    }
}

// MARK: - DropHandler

struct DropHandler: DropDelegate {
    let dayIndex: Int
    let data: AppData

    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [UTType.text]).first else { return false }
        item.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { raw, _ in
            if let d = raw as? Data,
               let s = String(data: d, encoding: .utf8),
               let uuid = UUID(uuidString: s),
               let template = data.plans.first(where: { $0.id == data.activePlanId })?
                   .muscleGroups.first(where: { $0.id == uuid })
            {
                let newMG = MuscleGroup(id: UUID(), name: template.name)
                DispatchQueue.main.async {
                    var p = data.activePlan!
                    p.days[dayIndex].muscleGroups.append(newMG)
                    data.activePlan = p
                }
            }
        }
        return true
    }
}

// MARK: - DayDetailCell

struct DayDetailCell: View {
    @EnvironmentObject var data: AppData
    let dayIndex: Int
    @State private var editing = false

    var body: some View {
        if let plan = data.activePlan, dayIndex < plan.days.count {
            let day = plan.days[dayIndex]
            VStack(alignment: .leading) {
                Text(day.title.isEmpty ? "Titolo giorno \(dayIndex+1)" : day.title)
                    .foregroundColor(.gray)
                Text(day.description.isEmpty ? "Descrizione e appunti allenamento \(dayIndex+1)" : day.description)
                    .foregroundColor(.gray)
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).stroke())
            .onTapGesture { editing = true }
            .sheet(isPresented: $editing) {
                DetailEditor(dayIndex: dayIndex, isPresented: $editing)
                    .environmentObject(data)
            }
        }
    }
}

// MARK: - DetailEditor

struct DetailEditor: View {
    @EnvironmentObject var data: AppData
    let dayIndex: Int
    @Binding var isPresented: Bool
    @State private var titleText = ""
    @State private var descText = ""

    var body: some View {
        VStack {
            HStack {
                Button("Annulla") { isPresented = false }
                Spacer()
                Button("Salva") {
                    var p = data.activePlan!
                    p.days[dayIndex].title = titleText
                    p.days[dayIndex].description = descText
                    data.activePlan = p
                    isPresented = false
                }
            }
            .padding()
            Divider()
            TextField("Titolo giorno", text: $titleText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextEditor(text: $descText)
                .frame(height: 200)
                .border(Color.gray)
                .padding()
            Spacer()
        }
        .onAppear {
            let day = data.activePlan!.days[dayIndex]
            titleText = day.title
            descText = day.description
        }
        .onChange(of: data.activePlan?.days.count ?? 0) { _, newCount in
            if dayIndex >= newCount { isPresented = false }
        }
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    @EnvironmentObject var data: AppData
    @Environment(\.dismiss) var dismiss
    @Binding var pendingLength: Int
    @State private var showDeleteConfirm = false
    @State private var showExplanation = false

    var body: some View {
        // Pre-calcolo fuori dal ViewBuilder
        let days = data.activePlan?.days ?? []
        let options: [(id: UUID, label: String)] = days.enumerated().map { idx, d in
            let title = d.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let label: String
            if !title.isEmpty {
                // 1) se c'è titolo, mostro il titolo
                label = title
            } else if !d.muscleGroups.isEmpty {
                // se non c'è titolo ma ci sono gruppi, li unisco con " + "
                label = d.muscleGroups.map(\.name).joined(separator: " + ")
            } else {
                // NOVITÀ: se è vuoto e senza titolo, mostro "Pausa"
                label = "Pausa"
            }
            return (d.id, label)
        }

        NavigationView {
            Form {
                Section("Nome scheda") {
                    TextField("Nome", text: Binding(
                        get: { data.activePlan!.name },
                        set: { data.activePlan!.name = $0 }
                    ))
                }

                Section("Lunghezza (giorni)") {
                    Stepper("\(pendingLength) giorni", value: $pendingLength, in: 1...100)
                }

                Section("Primo giorno della scheda dopo lunga pausa") {
                    Picker("Seleziona", selection: Binding<UUID?>(
                        get: { data.activePlan?.startAfterLongPauseDayId },
                        set: { data.activePlan?.startAfterLongPauseDayId = $0 }
                    )) {
                        Text("Nessuno").tag(UUID?.none)
                        ForEach(options, id: \.id) { opt in
                            Text(opt.label).tag(Optional(opt.id))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section("Dopo quanti giorni si considera lunga pausa?") {
                    Stepper(
                        "\(data.activePlan!.minLongPauseDays) giorni",
                        value: Binding(
                            get: { data.activePlan!.minLongPauseDays },
                            set: { data.activePlan!.minLongPauseDays = $0 }
                        ),
                        in: 1...100
                    )
                }

                Section("Logica scheda") {
                    Toggle("Da seguire strettamente", isOn: Binding(
                        get: { data.activePlan!.strictMode },
                        set: { data.activePlan!.strictMode = $0 }
                    ))
                    DisclosureGroup("Spiegazione", isExpanded: $showExplanation) {
                        ScrollView {
                            Text("""
                            La clausola di regidità garantisce che ogni allenamento venga considerato valido solo se non si sono allenati gruppi muscolare ulteriori (non inclusi) rispetto al giorno previsto nella sequenza della scheda.
                            Senza rigidità, si avrà corrispondenza semplicemente se almeno uno dei gruppi muscolari allenati compare nel giorno della scheda.
                            """)
                                .font(.footnote)
                                .padding(.vertical, 4)
                        }
                        .frame(maxHeight: 200)
                    }
                }

                if data.plans.count > 1 {
                    Section {
                        Button("Elimina scheda", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    }
                }
            }
            .navigationTitle("Impostazioni")
            .alert("Sei sicuro di voler eliminare questa scheda?", isPresented: $showDeleteConfirm) {
                Button("Elimina", role: .destructive) {
                    if let id = data.activePlanId {
                        data.plans.removeAll { $0.id == id }
                        data.activePlanId = data.plans.first?.id
                    }
                    dismiss()
                }
                Button("Annulla", role: .cancel) {}
            }
        }
    }
}

// MARK: - CalendarView

struct CalendarView: View {
    @EnvironmentObject var data: AppData
    @State private var selectedMonth = Date()
    @State private var showRange = false
    @State private var rangeStart = Date()
    @State private var rangeEnd = Date()
    @State private var showHistory = false

    // Confirm >100 days pause
    @State private var showLongPauseAlert = false
    @State private var longPauseCount = 0

    // Alert for skipped pauses
    @State private var showSkipAlert = false

    private var months: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let curr = today.startOfMonth
        let logMonths = data.workoutLogs.map { $0.date.startOfMonth }
        let earliestLog = logMonths.min() ?? curr
        let sixAgo = cal.date(byAdding: .month, value: -6, to: curr)!
        let defaultEarliest = min(earliestLog, sixAgo)
        let earliest = data.historyStartMonth?.startOfMonth ?? defaultEarliest

        var m = earliest, arr: [Date] = []
        while m <= curr {
            arr.append(m)
            m = cal.date(byAdding: .month, value: 1, to: m)!
        }
        if let next = cal.date(byAdding: .month, value: 1, to: curr) {
            arr.append(next)
        }
        return arr
    }

    var body: some View {
        VStack {
            HStack {
                Menu {
                    ForEach(data.plans) { plan in
                        Button {
                            data.activePlanId = plan.id
                        } label: {
                            HStack {
                                Text(plan.name)
                                Spacer()
                                if plan.id == data.activePlanId {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text("Scheda")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack(spacing: 4) {
                            Text(
                                data.plans
                                    .first { $0.id == data.activePlanId }?
                                    .name
                                ?? "Seleziona"
                            )
                            Image(systemName: "chevron.down")
                        }
                        .font(.headline).bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                }
                Spacer()
                Button("Data inizio registro") { showHistory = true }
                Spacer()
                Button("Inserire pausa lunga") {
                    rangeStart = Date()
                    rangeEnd = Date()
                    showRange = true
                }
            }
            .padding()

            TabView(selection: $selectedMonth) {
                ForEach(months, id: \.self) { m in
                    MonthView(month: m).tag(m)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear {
                selectedMonth = months.last { $0 <= Calendar.current.startOfDay(for: Date()) } ?? months.first!
            }
        }
        // Pause range sheet
        .sheet(isPresented: $showRange) {
            NavigationView {
                Form {
                    DatePicker("Da", selection: $rangeStart, in: ...Date(), displayedComponents: .date)
                    DatePicker("A", selection: $rangeEnd, in: rangeStart...Date(), displayedComponents: .date)
                }
                .navigationTitle("Inserisci pausa lunga")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annulla") { showRange = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Salva") {
                            let cal = Calendar.current
                            let diff = cal.dateComponents([.day], from: cal.startOfDay(for: rangeStart), to: cal.startOfDay(for: rangeEnd)).day ?? 0
                            let count = diff + 1
                            longPauseCount = count
                            if count > 100 {
                                showLongPauseAlert = true
                            } else {
                                performLongPause()
                            }
                        }
                    }
                }
            }
        }
        // Alert for >100 days
        .alert("Attenzione: stai per inserire \(longPauseCount) giorni di pausa di fila, da \(DateFormatter.localizedString(from: rangeStart, dateStyle: .short, timeStyle: .none)) a \(DateFormatter.localizedString(from: rangeEnd, dateStyle: .short, timeStyle: .none)), continuare?", isPresented: $showLongPauseAlert) {
            Button("Annulla", role: .cancel) {
                showLongPauseAlert = false
            }
            Button("Continua") {
                performLongPause()
            }
        }
        // Alert for skipped days
        .alert("Attenzione: avevi provato a sovrascrivere \(data.skippedPauseDates.count) allenamenti con delle pause. Li abbiamo invece lasciati intatti. Prova a controllare:\n" + data.skippedPauseDates.map {
            DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
        }.joined(separator: ", "), isPresented: $showSkipAlert) {
            Button("OK", role: .cancel) { }
        }
        // History start sheet
        .sheet(isPresented: $showHistory) {
            NavigationView {
                let previousMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
                let tenYearsBeforeDate = months.first.flatMap {
                    Calendar.current.date(byAdding: .year, value: -10, to: $0)
                }
                Form {
                    if let tenYearsBefore = tenYearsBeforeDate {
                        MonthYearPicker(
                            date: Binding(
                                get: { data.historyStartMonth ?? Date() },
                                set: { newDate in
                                    let clamped = min(max(newDate, tenYearsBefore), previousMonthDate)
                                    data.historyStartMonth = clamped
                                }
                            ),
                            minYear: Calendar.current.component(.year, from: tenYearsBefore),
                            maxYear: Calendar.current.component(.year, from: previousMonthDate)
                        )
                    } else {
                        MonthYearPicker(
                            date: Binding(
                                get: { data.historyStartMonth ?? Date() },
                                set: { newDate in
                                    let clamped = min(newDate, previousMonthDate)
                                    data.historyStartMonth = clamped
                                }
                            ),
                            minYear: Calendar.current.component(.year, from: previousMonthDate),
                            maxYear: Calendar.current.component(.year, from: previousMonthDate)
                        )
                    }
                }
                .navigationTitle("Mostra storico da")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annulla") { showHistory = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Salva") { showHistory = false }
                    }
                }
            }
        }
        .environment(\.locale, Locale(identifier: "it_IT"))
    }

    private func performLongPause() {
        let skipped = data.insertLongPause(from: rangeStart, to: rangeEnd)
        showRange = false
        if !skipped.isEmpty {
            showSkipAlert = true
        }
        showLongPauseAlert = false
    }
}

// MARK: - MonthYearPicker

struct MonthYearPicker: View {
    @Binding var date: Date
    let minYear: Int
    let maxYear: Int

    private let calendar = Calendar.current
    private let monthNames: [String] = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "it_IT")
        return df.monthSymbols.map { $0.capitalized }
    }()

    private var years: [Int] { Array(minYear...maxYear) }

    var body: some View {
        HStack {
            Picker("Mese", selection: monthBinding) {
                ForEach(1...12, id: \.self) { idx in
                    Text(monthNames[idx-1]).tag(idx)
                }
            }
            .pickerStyle(WheelPickerStyle())

            Picker("Anno", selection: yearBinding) {
                ForEach(years, id: \.self) { y in
                    Text("\(y)").tag(y)
                }
            }
            .pickerStyle(WheelPickerStyle())
        }
    }

    private var monthBinding: Binding<Int> {
        Binding(
            get: { calendar.component(.month, from: date) },
            set: { newMonth in
                var comps = calendar.dateComponents([.year, .month], from: date)
                comps.month = newMonth
                comps.day = 1
                date = calendar.date(from: comps)!
            }
        )
    }

    private var yearBinding: Binding<Int> {
        Binding(
            get: { calendar.component(.year, from: date) },
            set: { newYear in
                var comps = calendar.dateComponents([.year, .month], from: date)
                comps.year = newYear
                comps.day = 1
                date = calendar.date(from: comps)!
            }
        )
    }
}

// MARK: - MonthView

struct MonthView: View {
    @EnvironmentObject var data: AppData
    let month: Date
    @State private var showDeleteAlert = false

    private var hasEntries: Bool {
        let cal = Calendar.current
        let monthStart = month
        guard let nextMonth = cal.date(byAdding: .month, value: 1, to: monthStart) else { return false }
        return data.workoutLogs.contains { log in
            log.date >= monthStart && log.date < nextMonth
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(daysIn(month), id: \.self) { date in
                    DayCell(date: date).environmentObject(data)
                }
                if hasEntries {
                    Spacer(minLength: 20)
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Text("Elimina allenamenti del mese")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal)
                    .alert("Conferma eliminazione", isPresented: $showDeleteAlert) {
                        Button("Elimina", role: .destructive) {
                            deleteMonth()
                        }
                        Button("Annulla", role: .cancel) { }
                    } message: {
                        Text("Sei sicuro di voler eliminare tutti gli allenamenti del mese selezionato?")
                    }
                }
            }
            .padding()
        }
    }

    private func deleteMonth() {
        let cal = Calendar.current
        let monthStart = month
        guard let nextMonth = cal.date(byAdding: .month, value: 1, to: monthStart) else { return }
        data.workoutLogs.removeAll { log in
            log.date >= monthStart && log.date < nextMonth
        }
    }

    private func daysIn(_ month: Date) -> [Date] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: month) else { return [] }
        let comps = cal.dateComponents([.year, .month], from: month)
        return range.compactMap { day -> Date? in
            var c = comps; c.day = day
            return cal.date(from: c)
        }
    }
}

// MARK: - DayCell

struct DayCell: View {
    @EnvironmentObject var data: AppData
    let date: Date
    @State private var showEditor = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()
    
    private var entry: WorkoutLogEntry? {
        data.workoutLogs.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    var body: some View {
        HStack {
            Text(Self.dateFormatter.string(from: date))
            Spacer()
            if let e = entry {
                Text(e.isLongPause
                     ? "Pausa"
                     : e.muscleGroups.map(\.name).joined(separator: " + "))
                    .foregroundColor(e.isLongPause ? .gray : .primary)
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).stroke())
        .contentShape(Rectangle())
        .onTapGesture {
            if date <= Date() { showEditor = true }
        }
        .sheet(isPresented: $showEditor) {
            DayLogView(date: date).environmentObject(data)
        }
    }
}

struct DayLogView: View {
    @EnvironmentObject var data: AppData
    let date: Date
    @Environment(\.dismiss) var dismiss

    @State private var selected: Set<UUID> = []
    @State private var newGroups: [MuscleGroup] = []
    @State private var adding = false
    @State private var newName = ""

    private var existing: WorkoutLogEntry? {
        data.workoutLogs.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    private func preview() -> String {
        let planNames = data.activePlan?.muscleGroups
            .filter { selected.contains($0.id) }
            .map(\.name) ?? []
        let customNames = newGroups
            .filter { selected.contains($0.id) }
            .map(\.name)
        let all = planNames + customNames
        return all.isEmpty ? "Pausa" : all.joined(separator: " + ")
    }

    private var isPause: Bool { preview() == "Pausa" }

    var body: some View {
        VStack {
            HStack {
                Button(isPause ? "Elimina" : "Svuota", role: .destructive) {
                    if isPause {
                        data.workoutLogs.removeAll {
                            Calendar.current.isDate($0.date, inSameDayAs: date)
                        }
                        dismiss()
                    } else {
                        selected.removeAll()
                        newGroups.removeAll()
                    }
                }

                Spacer()

                Text("Allenamento \(date.formatted("dd/MM/yyyy"))")
                    .font(.headline)

                Spacer()

                Button("Salva") {
                    let planGroups = data.activePlan?.muscleGroups
                        .filter { selected.contains($0.id) } ?? []
                    let customGroups = newGroups
                        .filter { selected.contains($0.id) }
                    data.saveWorkout(on: date, groups: planGroups + customGroups)
                    dismiss()
                }
            }
            .padding()

            Text(preview())
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.2))

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Button("Altro") { adding = true }
                        .padding(6)

                    ForEach(data.activePlan?.muscleGroups ?? []) { g in
                        SelectionBlock(
                            group: g,
                            isSelected: selected.contains(g.id)
                        ) { toggle(g.id) }
                    }
                    ForEach(newGroups) { g in
                        SelectionBlock(
                            group: g,
                            isSelected: selected.contains(g.id)
                        ) { toggle(g.id) }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $adding) {
            NavigationView {
                Form {
                    TextField("Nome gruppo", text: $newName)
                }
                .navigationTitle("Specifica")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annulla") {
                            adding = false
                            newName = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Aggiungi") {
                            let g = MuscleGroup(id: UUID(), name: newName)
                            newGroups.append(g)
                            selected.insert(g.id)
                            adding = false
                            newName = ""
                        }
                    }
                }
            }
        }
        .onAppear {
            guard let e = existing else { return }
            // reset selezioni
            selected.removeAll()
            newGroups.removeAll()

            // dividiamo i gruppi esistenti in "piano" vs "custom"
            let planIDs = Set(data.activePlan?.muscleGroups.map(\.id) ?? [])
            for mg in e.muscleGroups {
                if planIDs.contains(mg.id) {
                    // è un gruppo della scheda: lo seleziono
                    selected.insert(mg.id)
                } else {
                    // non è nella scheda: lo trattiamo da "Altro"
                    newGroups.append(mg)
                    selected.insert(mg.id)
                }
            }
        }
    }

    private func toggle(_ id: UUID) {
        if selected.contains(id) {
            selected.remove(id)
        } else {
            selected.insert(id)
        }
    }
}

// MARK: - SelectionBlock

struct SelectionBlock: View {
    let group: MuscleGroup
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(group.name)
            .padding(6)
            .background(RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.yellow.opacity(0.5) : Color.clear))
            .onTapGesture(perform: action)
    }
}

// MARK: - PalestraNavButton

struct PalestraNavButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavigationLink {
                        VisioneIngressoView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Text("PALESTRA")
                            .font(.system(size: 24, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                            .background(Color.PaletteGreen4Alt2)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
    }
}

extension View {
    func withPalestraButton() -> some View { modifier(PalestraNavButton()) }
}

// MARK: - IndietroBackButton

struct IndietroBackButton: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content.navigationBarBackButtonHidden(true)
    }
}

extension View {
    func withIndietroBack() -> some View {
        modifier(IndietroBackButton())
    }
}

// MARK: - ImportConfirmationView

struct ImportConfirmationView: View {
    let message: String
    let importAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            FluidBackground().ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Attenzione")
                    .font(.title).bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(message)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                HStack(spacing: 16) {
                    Button(action: cancelAction) {
                        Text("Annulla")
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .contentShape(RoundedRectangle(cornerRadius: 8))
                    Button(action: importAction) {
                        Text("Importa")
                            .bold()
                            .foregroundColor(.PaletteGreen6)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .contentShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal)
            }
            .padding(.top, 35)
        }
    }
}
