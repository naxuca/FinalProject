import SwiftUI

struct TaskItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
}

struct TodoView: View {
    @State private var tasksByDate: [String: [TaskItem]] = [:] {
        didSet { saveTasks() }
    }
    @State private var newTaskTitle = ""
    @State private var selectedDate = Date()
    @State private var showAllTasks = false
    
    private let calendar = Calendar.current

    var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: selectedDate)
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: "SavedTasks"),
           let decoded = try? JSONDecoder().decode([String: [TaskItem]].self, from: data) {
            _tasksByDate = State(initialValue: decoded)
        }
    }

    var body: some View {
        ZStack {
            Color(red: 22/255, green: 30/255, blue: 50/255)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                headerView
                
                if showAllTasks {
                    allTasksSummarySection
                } else {
                    calendarViewSection
                }
            }
            .padding(.top)
        }
    }

    
    private var headerView: some View {
        HStack {
            Text(showAllTasks ? "Agenda" : monthYearString(from: selectedDate))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { withAnimation { showAllTasks.toggle() } }) {
                Image(systemName: showAllTasks ? "calendar" : "list.bullet.below.rectangle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(12)
                    .background(Color.white.opacity(0.1), in: Circle())
            }
        }
        .padding(.horizontal)
    }

    private var calendarViewSection: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left").foregroundColor(.blue).padding(8)
                }
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right").foregroundColor(.blue).padding(8)
                }
            }
            .padding(.horizontal)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(daysInMonth(), id: \.self) { date in
                            DayCard(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate)) {
                                selectedDate = date
                            }
                            .id(date)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: selectedDate) { newDate in
                    withAnimation { proxy.scrollTo(newDate, anchor: .center) }
                }
            }
            
            HStack(spacing: 15) {
                TextField("New task...", text: $newTaskTitle)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    .foregroundColor(.white)
                    .onSubmit(addTask)
                
                Button(action: addTask) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            currentDayTaskList
        }
    }

    private var currentDayTaskList: some View {
        List {
            if let tasks = tasksByDate[dateKey], !tasks.isEmpty {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    taskRow(task: task, index: index, key: dateKey)
                }
            } else {
                Text("No tasks for today").foregroundColor(.gray).listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
    }

    private var allTasksSummarySection: some View {
        List {
            let sortedKeys = tasksByDate.keys.sorted(by: >)
            if sortedKeys.isEmpty {
                Text("Your agenda is empty").foregroundColor(.gray).listRowBackground(Color.clear)
            } else {
                ForEach(sortedKeys, id: \.self) { key in
                    Section(header: Text(formatKeyDate(key)).foregroundColor(.blue).bold()) {
                        let tasks = tasksByDate[key] ?? []
                        ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                            taskRow(task: task, index: index, key: key)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }

    func taskRow(task: TaskItem, index: Int, key: String) -> some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .green : .blue)
                .onTapGesture {
                    withAnimation { tasksByDate[key]?[index].isCompleted.toggle() }
                }
            
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .gray : .white)
            
            Spacer()
        }
        .listRowBackground(Color.white.opacity(0.05))
        .swipeActions {
            Button(role: .destructive) {
                withAnimation {
                    tasksByDate[key]?.remove(at: index)
                    if tasksByDate[key]?.isEmpty == true { tasksByDate.removeValue(forKey: key) }
                }
            } label: { Label("Delete", systemImage: "trash") }
        }
    }

    
    func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        withAnimation {
            tasksByDate[dateKey, default: []].append(TaskItem(title: newTaskTitle))
            newTaskTitle = ""
        }
    }

    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasksByDate) {
            UserDefaults.standard.set(encoded, forKey: "SavedTasks")
        }
    }

    func daysInMonth() -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))
        else { return [] }
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth) }
    }

    func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    func monthYearString(from date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"; return f.string(from: date)
    }

    func formatKeyDate(_ key: String) -> String {
        let inputFormatter = DateFormatter(); inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: key) else { return key }
        let outputFormatter = DateFormatter(); outputFormatter.dateFormat = "EEEE, d MMMM"
        return outputFormatter.string(from: date)
    }
}

struct DayCard: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(getDayName(date))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isSelected ? .white : .gray)
                
                Text(getDayNumber(date))
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.white)
            }
            .frame(width: 50, height: 75)
            .background(isSelected ? Color.blue : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
    }
    
    private func getDayName(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "EEE"; return f.string(from: date).uppercased()
    }
    private func getDayNumber(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "d"; return f.string(from: date)
    }
}
