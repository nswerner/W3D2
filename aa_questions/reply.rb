require_relative 'forum.rb'

class Reply

    attr_accessor :parent_id, :body, :user_id, :question_id 
    attr_reader :id

    def self.all
        data = ForumDBConnection.instance.execute('SELECT * FROM replies;')
        data.map { |datum| Reply.new(datum)}
    end 

    def self.find_by_id(id)
        ForumDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                replies
            WHERE
                replies.id = ?
        SQL
    end 

    def self.find_by_author_id(user_id)
        ForumDBConnection.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
                replies
            WHERE
                replies.user_id = ?
        SQL
    end

    def self.find_by_question_id(question_id)
        ForumDBConnection.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                replies
            WHERE
                replies.question_id = ?
        SQL
    end

    def initialize(options)
        @id = options['id']
        @body = options['body']
        @parent_id = options['parent_id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end

    def create
        raise "That reply already exists" if id

        ForumDBConnection.instance.execute(<<-SQL, body, parent_id, user_id, question_id)
            INSERT INTO 
                replies (body, parent_id, user_id, question_id) 
            VALUES 
                (?, ?, ?, ?)
        SQL

        @id = ForumDBConnection.instance.last_insert_row_id
    end

    def update 
        raise "Reply does not exist" unless id 

        ForumDBConnection.instance.execute(<<-SQL, body, parent_id, user_id, question_id, id)
            UPDATE
                replies 
            SET 
                body = ?, parent_id = ?, user_id = ?, question_id = ?
            WHERE 
                id = ? 
        SQL
    end 

    def author
        User.find_by_id(self.user_id)
    end

    def question 
        Question.find_by_id(self.question_id)
    end 

    def parent_reply
        Reply.find_by_id(self.parent_id)
    end 

    # def child_replies
    #     ForumDBConnection.instance.execute(<<-SQL, question_id, id)
    #         SELECT
    #             *
    #         FROM
    #             replies
    #         WHERE
    #             question_id = ? AND parent_id >= ?
    #     SQL
    # end 

    def child_replies
        ForumDBConnection.instance.execute(<<-SQL, question_id, id)
            SELECT
                *
            FROM
                replies
            WHERE
                question_id = ? AND parent_id = ?
        SQL
    end 
end