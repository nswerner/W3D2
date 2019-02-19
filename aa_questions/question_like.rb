require_relative 'forum'

class QuestionLike
    attr_accessor :user_id, :question_id 
    attr_reader :id 

    def self.all
        data = ForumDBConnection.instance.execute('SELECT * FROM question_likes')
        data.map { |datum| QuestionLike.new(datum) }
    end 

     def self.find_by_id(id)
        question_like = ForumDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                question_likes
            WHERE
                id = ?
        SQL

        QuestionLike.new(question_like.first)
    end

    def self.likers_for_question_id(question_id)
        users = ForumDBConnection.instance.execute(<<-SQL, question_id)
            SELECT 
                user_id AS id, fname, lname 
            FROM 
                question_likes 
            JOIN 
                users ON users.id = question_likes.user_id 
            WHERE 
                question_id = ?
        SQL

        users.map { |user_options| User.new(user_options) }
    end

     def self.num_likes_for_question_id(question_id)
        num_likes = ForumDBConnection.instance.execute(<<-SQL, question_id)
            SELECT 
                COUNT(id) AS "Number of Likes"
            FROM 
                question_likes 
            WHERE
                question_id = ?
            GROUP BY 
                question_id 
        SQL

        num_likes.first["Number of Likes"]
    end 

    def self.liked_questions_for_user_id(user_id)
        questions = ForumDBConnection.instance.execute(<<-SQL, user_id)
            SELECT 
                question_likes.question_id AS id, title, body, question_likes.user_id
            FROM 
                question_likes 
            JOIN 
                questions ON questions.id = question_likes.question_id 
            WHERE 
                question_likes.user_id = ?
        SQL

        questions.map { |question_options| Question.new(question_options) }
    end

    def self.most_liked_questions(n)
        most_liked_qs = ForumDBConnection.instance.execute(<<-SQL, n)
            SELECT 
                question_id AS id 
            FROM 
                question_likes
            GROUP BY 
                question_id 
            ORDER BY 
                COUNT(id) DESC 
            LIMIT ?;
        SQL

        array_of_question_options = most_liked_qs.map { |q_id| Question.find_by_id(q_id['id']).first} 
        array_of_question_options.map { |options| Question.new(options)}
    end 
    
    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end

    def create
        raise "That Like already exists" if id

        ForumDBConnection.instance.execute(<<-SQL, user_id, question_id)
            INSERT INTO 
                question_likes (user_id, question_id) 
            VALUES 
                (?, ?)
        SQL

        @id = ForumDBConnection.instance.last_insert_row_id
    end

    def update 
        raise "Like does not exist" unless id 

        ForumDBConnection.instance.execute(<<-SQL, user_id, question_id, id)
            UPDATE
                question_likes 
            SET 
                user_id = ?, question_id = ?
            WHERE 
                id = ? 
        SQL
    end 

end