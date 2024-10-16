# app/components/tasks_accordion.rb
class TasksAccordion < ApplicationComponent
  def initialize(tasks:)
    @tasks = tasks
  end

  def view_template
    div class: "accordion", id: "tasksAccordion" do
      @tasks.each do |task|
        div class: "accordion-item", id: "task-#{task.id}" do
          h2 class: "accordion-header", id: "heading#{task.id}" do
            button class: "accordion-button collapsed bg-secondary text-light", type: "button", data: { bs_toggle: "collapse", bs_target: "#collapse#{task.id}" }, aria_expanded: "false", aria_controls: "collapse#{task.id}" do
              strong { task.title }
              plain " - Priority: #{task.priority.humanize.capitalize} | Board: #{task.board.name}"
            end
          end

          div id: "collapse#{task.id}", class: "accordion-collapse collapse", aria_labelledby: "heading#{task.id}", data: { bs_parent: "#tasksAccordion" } do
            div class: "accordion-body bg-dark text-light" do
              p do
                strong { "Description:" }
                plain " #{task.description}"
              end

              p do
                strong { "Due Date:" }
                plain " #{task.due_date.strftime('%d %b %Y')}"
              end

              p do
                strong { "Status:" }
                form action: board_tasks_page_path(task.board, task), method: :patch, class: "mt-2" do
                  select name: "task[status]", class: "form-select bg-secondary text-light" do
                    Task.statuses.keys.each do |status|
                      option selected: (task.status == status), value: status do
                        plain status.humanize.capitalize
                      end
                    end
                  end
                  button class: "btn btn-outline-light mt-2", type: "submit" do
                    plain "Update"
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
