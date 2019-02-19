require_relative 'forum.rb'
require_relative 'user.rb'
require_relative 'question.rb'

class QuestionFollow
    attr_accessor :user_id, :question_id
    attr_reader :id
    
    def self.all
        data = ForumDBConnection.instance.execute("SELECT * FROM question_follows")
        # data.map(&:QuestionFollow.new)
        data.map { |datum| QuestionFollow.new(datum)}
    end 

    def self.find_by_id(id)
        ForumDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                question_follows
            WHERE
                id = ?
        SQL
    end

    def self.followers_for_question_id(question_id)
        users = ForumDBConnection.instance.execute(<<-SQL, question_id)
            SELECT 
                user_id AS id, fname, lname 
            FROM 
                question_follows 
            JOIN 
                users ON users.id = question_follows.user_id 
            WHERE 
                question_id = ?
        SQL

        users.map { |user_options| User.new(user_options) }
    end

    def self.followed_questions_for_user_id(user_id)
        questions = ForumDBConnection.instance.execute(<<-SQL, user_id)
            SELECT
                question_id AS id, title, body, q.user_id
            FROM
                question_follows qf
            JOIN
                questions q on q.id = qf.question_id
            WHERE
                qf.user_id = ?
        SQL

        questions.map { |question_options| Question.new(question_options) }
    end 

    def self.most_followed_questions(n)
        most_followed_qs = ForumDBConnection.instance.execute(<<-SQL, n)
            SELECT 
                question_id AS id 
            FROM 
                question_follows 
            GROUP BY 
                question_id 
            ORDER BY 
                COUNT(id) DESC 
            LIMIT ?;
        SQL

        array_of_question_options = most_followed_qs.map { |q_id| Question.find_by_id(q_id['id']).first} 
        array_of_question_options.map { |options| Question.new(options)}
    end 

    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end

    def create
        raise "#{self} already exists" if id
        ForumDBConnection.instance.execute(<<-SQL, user_id, question_id)

         INSERT INTO 
                question_follows (user_id, question_id) 
            VALUES 
                (?, ?)
        SQL

        @id = ForumDBConnection.instance.last_insert_row_id
    end

    def update 
        raise "#{self} does not exist" unless id 

        ForumDBConnection.instance.execute(<<-SQL, user_id, question_id, id)
            UPDATE
                question_follows 
            SET 
               user_id = ?, question_id = ?
            WHERE 
                id = ? 
        SQL
    end


end