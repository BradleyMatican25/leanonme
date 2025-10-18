# ==================== LIBRARIES ====================
# Load all required packages first
library(shiny)
library(shinydashboard)
library(dplyr)
library(readr)
library(DT)
library(shinyalert)
library(plotly)
library(lubridate)

# ==================== UI DEFINITION ====================
ui <- dashboardPage(
  dashboardHeader(title = "🏥 St. Mary's Floor 3 - QC Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Live Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Staff Workload", tabName = "staff", icon = icon("users")),
      menuItem("Patient Details", tabName = "patients", icon = icon("bed")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    ),
    hr(),
    h4("Data Upload", style = "padding-left: 15px; color: white;"),
    fileInput("upload_data", "Upload Patient Visit Data", accept = ".csv"),
    hr(),
    h4("Filters", style = "padding-left: 15px; color: white;"),
    selectInput("acuity_filter", "Filter by Acuity:", 
                choices = c("All", "High", "Medium", "Low"), 
                selected = "All"),
    hr(),
    actionButton("refresh", "Refresh Alerts", icon = icon("sync"), 
                 style = "width: 90%; margin: 10px; background-color: #00a65a; color: white;"),
    hr(),
    h4("🤖 Chatbot Assistant", style = "padding-left: 15px; color: white;"),
    textInput("chat_input", NULL, 
              placeholder = "Ask: avg wait, max wait, busiest..."),
    actionButton("chat_send", "Ask Chatbot", icon = icon("comment"),
                 style = "width: 90%; margin: 10px; background-color: #3c8dbc; color: white;"),
    hr(),
    div(style = "padding: 15px; color: white; font-size: 11px;",
        strong("Facility Info:"), br(),
        "St. Mary's Hospital", br(),
        "Floor 3 - Med-Surg", br(),
        "80 beds | 6 nurses/shift", br(),
        "24/7 Operations"
    )
  ),
  
  dashboardBody(
    # Custom CSS
    tags$head(
      tags$style(HTML("
        .main-header .logo { font-weight: bold; font-size: 18px; }
        .info-box-text { font-weight: bold; }
        .box-title { font-weight: bold; font-size: 16px; }
        .help-text { color: #666; font-size: 12px; font-style: italic; margin-top: 5px; }
        .metric-description { font-size: 13px; color: #555; margin-bottom: 10px; }
      "))
    ),
    
    tabItems(
      # Tab 1: Live Dashboard
      tabItem("dashboard",
              h2("Live Patient Care Monitoring - Real-Time Status"),
              # Show upload prompt if no data
              conditionalPanel(
                condition = "output.data_loaded == false",
                div(style = "padding: 40px; text-align: center; background-color: #f9f9f9; border: 2px dashed #ccc; border-radius: 10px; margin: 20px;",
                    icon("upload", style = "font-size: 60px; color: #3c8dbc; margin-bottom: 20px;"),
                    h3("No Data Loaded", style = "color: #333; margin-bottom: 15px;"),
                    p("Please upload a CSV file using the 'Upload Patient Visit Data' button in the left sidebar.", 
                      style = "font-size: 16px; color: #666; margin-bottom: 10px;"),
                    p(strong("Required columns:"), "patient_id, room_number, acuity_level, assigned_nurse, hours_since_last_visit",
                      style = "font-size: 14px; color: #888;")
                )
              ),
              # Show dashboard content only when data is loaded
              conditionalPanel(
                condition = "output.data_loaded == true",
                div(class = "metric-description",
                    "Status Logic: OK (≤threshold) | WARNING (>threshold, ≤1.5×threshold) | CRITICAL (>1.5×threshold)"
                ),
                fluidRow(
                  valueBoxOutput("avg_wait_box", width = 3),
                  valueBoxOutput("max_wait_box", width = 3),
                  valueBoxOutput("alert_box", width = 3),
                  valueBoxOutput("compliance_box", width = 3)
                ),
                fluidRow(
                  box(title = "🔴 Critical Alerts - IMMEDIATE ACTION REQUIRED", 
                      status = "danger", solidHeader = TRUE,
                      div(class = "help-text", 
                          "HIGH: >3hrs | MEDIUM: >6hrs | LOW: >9hrs (all 1.5× acuity threshold)"),
                      DTOutput("critical_alerts_table"), width = 6),
                  box(title = "📊 Average Wait Time by Acuity Level", 
                      status = "primary", solidHeader = TRUE,
                      div(class = "help-text", 
                          "Thresholds: High=2hrs | Medium=4hrs | Low=6hrs"),
                      plotlyOutput("wait_time_chart"), width = 6)
                ),
                fluidRow(
                  box(title = "📋 Patient Status Overview - All Patients", 
                      status = "info", solidHeader = TRUE, width = 12,
                      div(class = "help-text", 
                          "Green = OK | Yellow = WARNING | Red = CRITICAL"),
                      DTOutput("patient_overview_table"))
                )
              )
      ),
      
      # Tab 2: Staff Workload
      tabItem("staff",
              h2("Staff Workload Analysis - Nurse Assignment Balance"),
              # Show upload prompt if no data
              conditionalPanel(
                condition = "output.data_loaded == false",
                div(style = "padding: 40px; text-align: center; background-color: #f9f9f9; border: 2px dashed #ccc; border-radius: 10px; margin: 20px;",
                    icon("upload", style = "font-size: 60px; color: #3c8dbc; margin-bottom: 20px;"),
                    h3("No Data Loaded", style = "color: #333; margin-bottom: 15px;"),
                    p("Please upload a CSV file to view staff workload analysis.", 
                      style = "font-size: 16px; color: #666;")
                )
              ),
              # Show content only when data is loaded
              conditionalPanel(
                condition = "output.data_loaded == true",
                div(class = "metric-description",
                    "Acuity Scoring: High=3 pts | Medium=2 pts | Low=1 pt | Target: 12-20 pts | Reassignment triggers at ±15% variance"
                ),
                fluidRow(
                  valueBoxOutput("workload_variance_box", width = 4),
                  valueBoxOutput("overloaded_staff_box", width = 4),
                  valueBoxOutput("underutilized_staff_box", width = 4)
                ),
                fluidRow(
                  box(title = "📊 Staff Workload Distribution", 
                      status = "primary", solidHeader = TRUE,
                      div(class = "help-text", 
                          "Target range (12-20 pts) shown with reference lines"),
                      plotlyOutput("workload_chart"), width = 6),
                  box(title = "💡 Reassignment Recommendations", 
                      status = "warning", solidHeader = TRUE,
                      div(class = "help-text", 
                          "Move LOW/MEDIUM patients from high-load to low-load nurses (±15% from mean triggers)"),
                      DTOutput("recommendations_table"), width = 6)
                ),
                fluidRow(
                  box(title = "📋 Staff Workload Details - Current Assignments", 
                      status = "info", solidHeader = TRUE, width = 12,
                      DTOutput("staff_detail_table"))
                )
              )
      ),
      
      # Tab 3: Patient Details
      tabItem("patients",
              h2("Complete Patient List - Current Status"),
              # Show upload prompt if no data
              conditionalPanel(
                condition = "output.data_loaded == false",
                div(style = "padding: 40px; text-align: center; background-color: #f9f9f9; border: 2px dashed #ccc; border-radius: 10px; margin: 20px;",
                    icon("upload", style = "font-size: 60px; color: #3c8dbc; margin-bottom: 20px;"),
                    h3("No Data Loaded", style = "color: #333; margin-bottom: 15px;"),
                    p("Please upload a CSV file to view patient details.", 
                      style = "font-size: 16px; color: #666;")
                )
              ),
              # Show content only when data is loaded
              conditionalPanel(
                condition = "output.data_loaded == true",
                div(class = "metric-description",
                    "All active patients on Floor 3. Use filter (left sidebar) to view by acuity level."
                ),
                fluidRow(
                  box(title = "📋 Patient List with Wait Times", 
                      status = "primary", solidHeader = TRUE, width = 12,
                      div(class = "help-text", 
                          "Color coding: Green (<3hrs) | Yellow (3-6hrs) | Red (>6hrs)"),
                      DTOutput("patient_table"))
                )
              )
      ),
      
      # Tab 4: About
      tabItem("about",
              h2("St. Mary's Hospital Floor 3 - Quality Control System"),
              box(width = 12, status = "primary", solidHeader = TRUE,
                  title = "🏥 Facility Profile",
                  fluidRow(
                    column(6,
                           h4("St. Mary's Hospital - Floor 3 (Medical-Surgical Unit)"),
                           tags$ul(
                             tags$li(strong("Bed Capacity:"), "80 beds across 20 rooms (Rooms 301-320)"),
                             tags$li(strong("Patient Volume:"), "60-80 patients daily (75-100% occupancy)"),
                             tags$li(strong("Services:"), "Post-surgical care, chronic disease management, pre-discharge observation"),
                             tags$li(strong("Staffing:"), "2 physicians, 9 nurses (6 on duty per shift)")
                           )
                    ),
                    column(6,
                           h4("Status Definitions"),
                           tags$ul(
                             tags$li(strong("OK:"), "Wait time ≤ acuity threshold"),
                             tags$li(strong("WARNING:"), "Wait time > threshold but ≤ 1.5× threshold"),
                             tags$li(strong("CRITICAL:"), "Wait time > 1.5× threshold (immediate action needed)")
                           ),
                           h4("Reassignment Logic"),
                           p("System recommends reassignments when workload variance exceeds ±15% from mean, 
                             moving low/medium acuity patients from above-mean to below-mean nurses.")
                    )
                  )
              )
      )
    )
  )
)

# ==================== SERVER DEFINITION ====================
server <- function(input, output, session) {
  
  # ===== WELCOME MESSAGE ON STARTUP =====
  observe({
    showModal(modalDialog(
      title = HTML("<div style='text-align: center;'>
                     <h3 style='margin: 0; color: #3c8dbc;'>🏥 Nurse Ticktock</h3>
                     <p style='margin: 5px 0; font-size: 14px; color: #666;'>Real-Time Quality Control for Inpatient Care</p>
                   </div>"),
      HTML("
        <div style='padding: 10px;'>
          <h4 style='color: #333; margin-top: 10px;'>📋 Purpose</h4>
          <p style='margin: 10px 0; line-height: 1.6;'>
            <strong>Nurse Ticktock</strong> is a quality control system designed to track and mitigate irregular wait times 
            in inpatient care through data-driven workload coordination. This dashboard helps:
          </p>
          <ul style='margin: 5px 0 15px 20px; line-height: 1.8;'>
            <li><strong>Monitor</strong> nursing visit frequency across all patients in real-time</li>
            <li><strong>Generate</strong> automated alerts when visit intervals exceed safe thresholds</li>
            <li><strong>Balance</strong> workload using acuity-weighted assignment algorithms</li>
            <li><strong>Recommend</strong> reassignments to optimize care coordination</li>
          </ul>
          
          <div style='background-color: #fff3cd; padding: 15px; border-radius: 5px; border-left: 4px solid #ffc107; margin: 20px 0;'>
            <h4 style='margin: 0 0 10px 0; color: #856404;'>⚠️ Getting Started: Upload Your Data</h4>
            <p style='margin: 5px 0; color: #856404;'><strong>This dashboard requires patient visit data to function.</strong></p>
            <ol style='margin: 10px 0 5px 20px; color: #856404; line-height: 1.8;'>
              <li>Click <strong>'Browse...'</strong> in the left sidebar under 'Upload Patient Visit Data'</li>
              <li>Select your CSV file with these required columns:
                <ul style='margin: 5px 0 5px 15px;'>
                  <li><code>patient_id</code> - Unique patient identifier</li>
                  <li><code>room_number</code> - Patient's room number</li>
                  <li><code>acuity_level</code> - High, Medium, or Low (case-sensitive)</li>
                  <li><code>assigned_nurse</code> - Assigned nurse ID</li>
                  <li><code>hours_since_last_visit</code> - Hours since last nursing visit</li>
                </ul>
              </li>
              <li>Once uploaded, explore the dashboard:
                <ul style='margin: 5px 0 5px 15px;'>
                  <li><strong>Live Dashboard</strong> - View patient status and critical alerts</li>
                  <li><strong>Staff Workload</strong> - Check workload balance and reassignment recommendations</li>
                  <li><strong>Patient Details</strong> - Review complete patient list with wait times</li>
                  <li><strong>Chatbot</strong> - Ask quick questions (e.g., 'avg wait', 'busiest staff')</li>
                </ul>
              </li>
            </ol>
          </div>
          
          <div style='background-color: #d1ecf1; padding: 12px; border-radius: 5px; border-left: 4px solid #17a2b8; margin: 15px 0;'>
            <p style='margin: 0; color: #0c5460; font-size: 13px;'>
              <strong>💡 Sample Data Available:</strong> You can test the dashboard using 
              <code>Mock Data Patients1.csv</code> or <code>Mock Data Patients2.csv</code> files.
            </p>
          </div>
          
          <p style='margin: 15px 0 5px 0; font-size: 12px; color: #999; text-align: center;'>
            <strong>Status Logic:</strong> OK (≤threshold) | WARNING (>threshold) | CRITICAL (>1.5×threshold)
          </p>
        </div>
      "),
      size = "l",
      easyClose = TRUE,
      footer = modalButton("Get Started")
    ))
  })
  
  # ===== REACTIVE DATA =====
  combined_data <- reactiveVal(NULL)
  
  # Output to track if data is loaded (for conditionalPanel)
  output$data_loaded <- reactive({
    !is.null(combined_data()) && nrow(combined_data()) > 0
  })
  outputOptions(output, "data_loaded", suspendWhenHidden = FALSE)
  
  # Data upload observer
  observe({
    req(input$upload_data)
    
    tryCatch({
      df <- read_csv(input$upload_data$datapath, show_col_types = FALSE)
      
      df <- df %>%
        mutate(
          threshold = case_when(
            acuity_level == "High" ~ 2,
            acuity_level == "Medium" ~ 4,
            acuity_level == "Low" ~ 6,
            TRUE ~ 4
          ),
          exceeds_threshold = hours_since_last_visit > threshold,
          severity = case_when(
            hours_since_last_visit > (threshold * 1.5) ~ "CRITICAL",
            hours_since_last_visit > threshold ~ "WARNING",
            TRUE ~ "OK"
          )
        )
      
      combined_data(df)
      
      showNotification(
        paste0("✅ Successfully loaded ", nrow(df), " patient records!"),
        type = "message",
        duration = 5
      )
      
    }, error = function(e) {
      showNotification(
        paste("❌ Error loading data:", e$message, 
              "\n\nPlease ensure your CSV has the required columns: patient_id, room_number, acuity_level, assigned_nurse, hours_since_last_visit"), 
        type = "error", 
        duration = 10
      )
    })
  })
  
  # ===== CALCULATED METRICS =====
  wait_times <- reactive({
    req(combined_data())
    combined_data()
  })
  
  staff_workload <- reactive({
    req(combined_data())
    
    tryCatch({
      df <- combined_data()
      if (nrow(df) == 0) return(data.frame())
      
      acuity_weights <- c("High" = 3, "Medium" = 2, "Low" = 1)
      
      workload <- df %>%
        group_by(assigned_nurse) %>%
        summarize(
          patients_assigned = n(),
          patients_high = sum(acuity_level == "High", na.rm = TRUE),
          patients_medium = sum(acuity_level == "Medium", na.rm = TRUE),
          patients_low = sum(acuity_level == "Low", na.rm = TRUE),
          total_acuity_score = sum(acuity_weights[acuity_level], na.rm = TRUE),
          .groups = "drop"
        )
      
      mean_score <- mean(workload$total_acuity_score)
      variance_threshold <- mean_score * 0.15
      
      workload <- workload %>%
        mutate(
          overloaded = total_acuity_score > (mean_score + variance_threshold),
          underutilized = total_acuity_score < (mean_score - variance_threshold),
          status = case_when(
            overloaded ~ "OVERLOADED",
            underutilized ~ "UNDERUTILIZED",
            TRUE ~ "OK"
          )
        )
      
      return(workload)
      
    }, error = function(e) {
      showNotification(paste("Error calculating staff workload:", e$message), type = "error")
      return(data.frame())
    })
  })
  
  system_metrics <- reactive({
    req(wait_times(), staff_workload())
    
    tryCatch({
      wt <- wait_times()
      sw <- staff_workload()
      
      if (nrow(wt) == 0) {
        return(list(
          total_patients = 0, avg_wait_time = 0, max_wait_time = 0,
          alert_count = 0, critical_alerts = 0, compliance_rate = 100,
          workload_variance = 0, overloaded_staff = 0, underutilized_staff = 0
        ))
      }
      
      total_patients <- nrow(wt)
      avg_wait <- mean(wt$hours_since_last_visit, na.rm = TRUE)
      max_wait <- max(wt$hours_since_last_visit, na.rm = TRUE)
      alert_count <- sum(wt$exceeds_threshold, na.rm = TRUE)
      critical_alerts <- sum(wt$severity == "CRITICAL", na.rm = TRUE)
      compliant_patients <- sum(!wt$exceeds_threshold, na.rm = TRUE)
      compliance_rate <- if(total_patients > 0) (compliant_patients / total_patients) * 100 else 100
      
      workload_variance <- if(nrow(sw) > 1) sd(sw$total_acuity_score, na.rm = TRUE) else 0
      overloaded_staff <- sum(sw$overloaded, na.rm = TRUE)
      underutilized_staff <- sum(sw$underutilized, na.rm = TRUE)
      
      list(
        total_patients = total_patients,
        avg_wait_time = round(avg_wait, 1),
        max_wait_time = round(max_wait, 1),
        alert_count = alert_count,
        critical_alerts = critical_alerts,
        compliance_rate = round(compliance_rate, 1),
        workload_variance = round(workload_variance, 1),
        overloaded_staff = overloaded_staff,
        underutilized_staff = underutilized_staff
      )
      
    }, error = function(e) {
      return(list(
        total_patients = 0, avg_wait_time = 0, max_wait_time = 0,
        alert_count = 0, critical_alerts = 0, compliance_rate = 0,
        workload_variance = 0, overloaded_staff = 0, underutilized_staff = 0
      ))
    })
  })
  
  recommendations <- reactive({
    req(combined_data(), staff_workload())
    
    tryCatch({
      df <- combined_data()
      sw <- staff_workload()
      
      if (nrow(sw) == 0) {
        return(data.frame(Message = "No workload data available"))
      }
      
      overloaded <- sw %>% filter(overloaded) %>% pull(assigned_nurse)
      underutilized <- sw %>% filter(underutilized) %>% pull(assigned_nurse)
      
      if (length(overloaded) == 0 | length(underutilized) == 0) {
        mean_score <- mean(sw$total_acuity_score)
        variance <- sd(sw$total_acuity_score)
        return(data.frame(
          Message = sprintf("✅ No reassignments needed - workload is balanced! (Mean: %.1f, Variance: %.1f)", 
                            mean_score, variance)
        ))
      }
      
      recommendations <- df %>%
        filter(assigned_nurse %in% overloaded,
               acuity_level %in% c("Low", "Medium")) %>%
        arrange(acuity_level, desc(hours_since_last_visit)) %>%
        head(5) %>%
        mutate(
          current_nurse = assigned_nurse,
          recommended_nurse = rep(underutilized, length.out = n()),
          reason = "Rebalance workload (±15% variance detected)"
        ) %>%
        select(patient_id, room_number, acuity_level, current_nurse, recommended_nurse, reason)
      
      if (nrow(recommendations) == 0) {
        return(data.frame(Message = "✅ Workload variance detected but no suitable patients to reassign"))
      }
      
      return(recommendations)
      
    }, error = function(e) {
      return(data.frame(Message = "Error generating recommendations"))
    })
  })
  
  # ===== CHATBOT FUNCTIONALITY =====
  chatbot_answer <- eventReactive(input$chat_send, {
    txt <- trimws(isolate(input$chat_input))
    if (nchar(txt) == 0) return("Please type a question for the chatbot.")
    
    if (is.null(combined_data()) || nrow(combined_data()) == 0) {
      return("⚠️ No data loaded yet. Please upload a CSV file first using the sidebar.")
    }
    
    txtl <- tolower(txt)
    wt <- wait_times()
    w <- staff_workload()
    
    if (grepl("avg", txtl) && grepl("wait", txtl)) {
      if (nrow(wt) == 0) return("No patient data available.")
      avg <- round(mean(wt$hours_since_last_visit, na.rm = TRUE), 2)
      return(paste0("Current average time since last visit: ", avg, " hours."))
    }
    
    if (grepl("max", txtl) && grepl("wait", txtl)) {
      if (nrow(wt) == 0) return("No patient data available.")
      mx <- round(max(wt$hours_since_last_visit, na.rm = TRUE), 2)
      pid <- wt$patient_id[which.max(wt$hours_since_last_visit)]
      return(paste0("Maximum time since visit is ", mx, " hours (Patient: ", pid, ")."))
    }
    
    if (grepl("busiest", txtl) || grepl("acuity", txtl)) {
      if (nrow(wt) == 0) return("No patient data available.")
      by_acuity <- wt %>% 
        group_by(acuity_level) %>% 
        summarise(n = n(), avg = mean(hours_since_last_visit, na.rm = TRUE), .groups = "drop")
      busiest <- by_acuity %>% filter(avg == max(avg, na.rm = TRUE)) %>% slice(1)
      return(paste0("Acuity level with highest average wait is ", 
                    busiest$acuity_level, " (", round(busiest$avg, 2), " hrs avg)."))
    }
    
    if (grepl("critical", txtl) || grepl("alert", txtl)) {
      ncrit <- sum(wt$severity == "CRITICAL", na.rm = TRUE)
      nwarn <- sum(wt$severity == "WARNING", na.rm = TRUE)
      return(paste0("There are ", ncrit, " CRITICAL and ", nwarn, " WARNING patients currently."))
    }
    
    if (grepl("overload", txtl) || grepl("staff", txtl)) {
      if (nrow(w) == 0) return("No workload data available.")
      ol <- w %>% arrange(desc(total_acuity_score)) %>% slice(1:3)
      return(paste0("Top loaded staff: ", paste(ol$assigned_nurse, " (", ol$total_acuity_score, " pts)", collapse = ", "), "."))
    }
    
    if (grepl("complian", txtl)) {
      metrics <- system_metrics()
      return(paste0("Current compliance rate: ", metrics$compliance_rate, "% (Target: >95%)"))
    }
    
    return("I can answer: 'avg wait', 'max wait', 'busiest acuity', 'critical alerts', 'overloaded staff', or 'compliance rate'.")
  })
  
  observe({
    if (input$chat_send > 0) {
      isolate({
        res <- chatbot_answer()
        showModal(modalDialog(
          title = "🤖 Chatbot Assistant",
          HTML(paste0("<p style='font-size: 14px;'>", res, "</p>")),
          easyClose = TRUE,
          footer = modalButton("Close")
        ))
      })
    }
  })
  
  # ===== VALUE BOXES =====
  output$avg_wait_box <- renderValueBox({
    metrics <- system_metrics()
    valueBox(
      paste0(metrics$avg_wait_time, " hrs"),
      "Average Wait Time (Target: <3.5hrs)",
      icon = icon("clock"),
      color = if (metrics$avg_wait_time > 4) "red" else if (metrics$avg_wait_time > 3) "yellow" else "green"
    )
  })
  
  output$max_wait_box <- renderValueBox({
    metrics <- system_metrics()
    valueBox(
      paste0(metrics$max_wait_time, " hrs"),
      "Maximum Wait Time (Target: <5.0hrs)",
      icon = icon("exclamation-triangle"),
      color = if (metrics$max_wait_time > 6) "red" else if (metrics$max_wait_time > 4) "yellow" else "green"
    )
  })
  
  output$alert_box <- renderValueBox({
    metrics <- system_metrics()
    valueBox(
      metrics$alert_count,
      "Active Alerts (Target: 0-2)",
      icon = icon("bell"),
      color = if (metrics$critical_alerts > 0) "red" else if (metrics$alert_count > 0) "yellow" else "green"
    )
  })
  
  output$compliance_box <- renderValueBox({
    metrics <- system_metrics()
    valueBox(
      paste0(metrics$compliance_rate, "%"),
      "Compliance Rate (Target: >95%)",
      icon = icon("check-circle"),
      color = if (metrics$compliance_rate < 85) "red" else if (metrics$compliance_rate < 95) "yellow" else "green"
    )
  })
  
  output$workload_variance_box <- renderValueBox({
    metrics <- system_metrics()
    valueBox(
      round(metrics$workload_variance, 1),
      "Workload Variance (Target: <4.0)",
      icon = icon("chart-line"),
      color = if (metrics$workload_variance > 6) "red" else if (metrics$workload_variance > 4) "yellow" else "green"
    )
  })
  
  output$overloaded_staff_box <- renderValueBox({
    metrics <- system_metrics()
    valueBox(
      metrics$overloaded_staff,
      "Overloaded Staff (>+15% mean)",
      icon = icon("user-times"),
      color = if (metrics$overloaded_staff > 0) "red" else "green"
    )
  })
  
  output$underutilized_staff_box <- renderValueBox({
    metrics <- system_metrics()
    valueBox(
      metrics$underutilized_staff,
      "Underutilized Staff (<-15% mean)",
      icon = icon("user-clock"),
      color = if (metrics$underutilized_staff > 1) "yellow" else "green"
    )
  })
  
  # ===== TABLES =====
  output$critical_alerts_table <- renderDT({
    tryCatch({
      wt <- wait_times()
      if (nrow(wt) == 0) {
        return(datatable(data.frame(Message = "No data available"), 
                         options = list(pageLength = 5, dom = 't'), rownames = FALSE))
      }
      
      wt_filtered <- wt %>%
        filter(severity == "CRITICAL") %>%
        select(Patient = patient_id, Room = room_number, Acuity = acuity_level,
               `Wait Time (hrs)` = hours_since_last_visit, Nurse = assigned_nurse) %>%
        mutate(`Wait Time (hrs)` = round(`Wait Time (hrs)`, 1))
      
      if (nrow(wt_filtered) == 0) {
        wt_filtered <- data.frame(Message = "✅ No critical alerts - all patients within standards!")
      }
      
      datatable(wt_filtered, options = list(pageLength = 5, dom = 't'), rownames = FALSE)
      
    }, error = function(e) {
      datatable(data.frame(Error = "Error loading table"), 
                options = list(pageLength = 5, dom = 't'), rownames = FALSE)
    })
  })
  
  output$patient_overview_table <- renderDT({
    tryCatch({
      wt <- wait_times()
      if (nrow(wt) == 0) {
        return(datatable(data.frame(Message = "No data available"), 
                         options = list(pageLength = 10), rownames = FALSE))
      }
      
      wt_display <- wt %>%
        select(Patient = patient_id, Room = room_number, Acuity = acuity_level,
               Nurse = assigned_nurse, `Hours Since Visit` = hours_since_last_visit,
               Status = severity) %>%
        mutate(`Hours Since Visit` = round(`Hours Since Visit`, 1))
      
      if (input$acuity_filter != "All") {
        wt_display <- wt_display %>% filter(Acuity == input$acuity_filter)
      }
      
      datatable(wt_display, options = list(pageLength = 10), rownames = FALSE) %>%
        formatStyle('Status',
                    backgroundColor = styleEqual(c('CRITICAL', 'WARNING', 'OK'),
                                                 c('#dd4b39', '#f39c12', '#00a65a')),
                    color = 'white')
      
    }, error = function(e) {
      datatable(data.frame(Error = "Error loading table"), 
                options = list(pageLength = 10), rownames = FALSE)
    })
  })
  
  output$patient_table <- renderDT({
    tryCatch({
      wt <- wait_times()
      if (nrow(wt) == 0) {
        return(datatable(data.frame(Message = "No data available"), 
                         options = list(pageLength = 20), rownames = FALSE))
      }
      
      wt_display <- wt %>%
        select(Patient = patient_id, Room = room_number, Acuity = acuity_level,
               Nurse = assigned_nurse, `Hours Since Visit` = hours_since_last_visit) %>%
        mutate(`Hours Since Visit` = round(`Hours Since Visit`, 1))
      
      datatable(wt_display, options = list(pageLength = 20), rownames = FALSE) %>%
        formatStyle('Hours Since Visit',
                    backgroundColor = styleInterval(c(3, 6),
                                                    c('#00a65a', '#f39c12', '#dd4b39')),
                    color = 'white')
      
    }, error = function(e) {
      datatable(data.frame(Error = "Error loading table"), 
                options = list(pageLength = 20), rownames = FALSE)
    })
  })
  
  output$staff_detail_table <- renderDT({
    tryCatch({
      sw <- staff_workload()
      if (nrow(sw) == 0) {
        return(datatable(data.frame(Message = "No data available"), 
                         options = list(pageLength = 10, dom = 't'), rownames = FALSE))
      }
      
      sw_display <- sw %>%
        select(Nurse = assigned_nurse, 
               `Total Patients` = patients_assigned,
               `High Acuity` = patients_high, 
               `Medium Acuity` = patients_medium, 
               `Low Acuity` = patients_low,
               `Acuity Score` = total_acuity_score, 
               Status = status)
      
      datatable(sw_display, options = list(pageLength = 10, dom = 't'), rownames = FALSE) %>%
        formatStyle('Status',
                    backgroundColor = styleEqual(c('OVERLOADED', 'OK', 'UNDERUTILIZED'),
                                                 c('#dd4b39', '#00a65a', '#f39c12')),
                    color = 'white')
      
    }, error = function(e) {
      datatable(data.frame(Error = "Error loading table"), 
                options = list(pageLength = 10, dom = 't'), rownames = FALSE)
    })
  })
  
  output$recommendations_table <- renderDT({
    tryCatch({
      recs <- recommendations()
      
      if ("Message" %in% names(recs)) {
        return(datatable(recs, options = list(pageLength = 5, dom = 't'), rownames = FALSE))
      }
      
      recs_display <- recs %>%
        select(Patient = patient_id, Room = room_number, Acuity = acuity_level,
               `From Nurse` = current_nurse, `To Nurse` = recommended_nurse, Reason = reason)
      
      datatable(recs_display, options = list(pageLength = 5, dom = 't'), rownames = FALSE)
      
    }, error = function(e) {
      datatable(data.frame(Error = "Error loading recommendations"), 
                options = list(pageLength = 5, dom = 't'), rownames = FALSE)
    })
  })
  
  # ===== CHARTS =====
  output$workload_chart <- renderPlotly({
    tryCatch({
      sw <- staff_workload()
      if (nrow(sw) == 0) {
        return(NULL)
      }
      
      mean_score <- mean(sw$total_acuity_score)
      
      plot_ly(sw, x = ~assigned_nurse, y = ~total_acuity_score, type = 'bar',
              color = ~status,
              colors = c("OVERLOADED" = "#dd4b39", "OK" = "#00a65a", "UNDERUTILIZED" = "#f39c12"),
              text = ~paste("Nurse:", assigned_nurse, 
                            "<br>Patients:", patients_assigned, 
                            "<br>Acuity Score:", total_acuity_score,
                            "<br>Status:", status),
              hoverinfo = 'text') %>%
        layout(title = list(text = "Staff Workload Distribution (Target: 12-20 points)", 
                            font = list(size = 14)),
               xaxis = list(title = "Nurse"),
               yaxis = list(title = "Acuity Score"),
               shapes = list(
                 list(type = "line", y0 = 20, y1 = 20, x0 = 0, x1 = 1, xref = "paper",
                      line = list(color = "red", dash = "dash", width = 2)),
                 list(type = "line", y0 = mean_score, y1 = mean_score, x0 = 0, x1 = 1, xref = "paper",
                      line = list(color = "blue", dash = "dot", width = 1.5))
               ),
               annotations = list(
                 list(x = 1, y = mean_score, xref = "paper", yref = "y",
                      text = paste("Mean:", round(mean_score, 1)), showarrow = FALSE,
                      xanchor = "right", font = list(size = 10, color = "blue"))
               ))
      
    }, error = function(e) {
      return(NULL)
    })
  })
  
  output$wait_time_chart <- renderPlotly({
    tryCatch({
      wt <- wait_times()
      if (nrow(wt) == 0) {
        return(NULL)
      }
      
      wt_summary <- wt %>%
        group_by(acuity_level) %>%
        summarize(avg_wait = mean(hours_since_last_visit, na.rm = TRUE), .groups = "drop")
      
      thresholds <- data.frame(
        acuity_level = c("High", "Medium", "Low"),
        threshold = c(2, 4, 6)
      )
      
      wt_summary <- wt_summary %>% left_join(thresholds, by = "acuity_level")
      
      p <- plot_ly() %>%
        add_bars(data = wt_summary, x = ~acuity_level, y = ~avg_wait, name = "Avg Wait Time",
                 marker = list(color = c("#dd4b39", "#f39c12", "#00a65a")),
                 text = ~paste("Acuity:", acuity_level, 
                               "<br>Avg Wait:", round(avg_wait, 1), "hrs"),
                 hoverinfo = 'text') %>%
        add_markers(data = wt_summary, x = ~acuity_level, y = ~threshold, name = "Threshold",
                    mode = 'markers',
                    marker = list(color = "black", size = 12, symbol = "line-ew"),
                    text = ~paste("Threshold:", threshold, "hrs"),
                    hoverinfo = 'text') %>%
        layout(title = list(text = "Wait Time vs Threshold by Acuity Level", 
                            font = list(size = 14)),
               xaxis = list(title = "Acuity Level"),
               yaxis = list(title = "Hours"),
               showlegend = TRUE)
      
      p
      
    }, error = function(e) {
      return(NULL)
    })
  })
  
  # ===== ALERTS =====
  observeEvent(input$refresh, {
    tryCatch({
      metrics <- system_metrics()
      
      if (metrics$critical_alerts > 0) {
        shinyalert(
          title = "🔴 CRITICAL ALERT",
          text = HTML(paste0(
            "<h4>", metrics$critical_alerts, " patients need IMMEDIATE attention!</h4>",
            "<p><strong>Response Required:</strong> Within 10 minutes</p>",
            "<p>Check the <strong>Live Dashboard</strong> tab for patient details.</p>"
          )),
          type = "error",
          html = TRUE
        )
      } else if (metrics$alert_count > 0) {
        shinyalert(
          title = "⚠️ Warning",
          text = HTML(paste0(
            "<h4>", metrics$alert_count, " patients approaching threshold.</h4>",
            "<p><strong>Response Required:</strong> Within 30 minutes</p>"
          )),
          type = "warning",
          html = TRUE
        )
      } else {
        shinyalert(
          title = "✅ All Clear",
          text = HTML(paste0(
            "<h4>All patients within care standards!</h4>",
            "<p><strong>Compliance Rate:</strong> ", metrics$compliance_rate, "%</p>",
            "<p>Great job maintaining quality care! 🏥</p>"
          )),
          type = "success",
          html = TRUE
        )
      }
      
    }, error = function(e) {
      shinyalert(
        title = "Error",
        text = paste("Error refreshing alerts:", e$message),
        type = "error"
      )
    })
  })
}

# ==================== RUN THE APP ====================
shinyApp(ui = ui, server = server)
